# Guards for the large-data import paths (MODA paging, incremental sync,
# label application, file readers, autosave gating).

test_that("MODA page size is large enough to avoid thousands of round-trips", {
  expect_gte(TargetWise:::MODA_PAGE_SIZE, 500L)
  expect_lte(TargetWise:::MODA_PAGE_SIZE, 10000L)  # ONA API ceiling
})

test_that("incremental MODA query filters on the newest _submission_time", {
  q <- TargetWise:::moda_incremental_query(NULL)
  expect_equal(q, "")

  df <- data.frame(`_submission_time` = c("2026-04-01T10:00:00", NA, "2026-04-03T09:30:00"),
                   check.names = FALSE, stringsAsFactors = FALSE)
  q <- TargetWise:::moda_incremental_query(df)
  expect_match(q, "^&query=")
  expect_true(grepl(utils::URLencode("2026-04-03T09:30:00", reserved = TRUE), q, fixed = TRUE))
  expect_false(grepl("2026-04-01", q, fixed = TRUE))

  # no timestamp column -> no filter (full download)
  expect_equal(TargetWise:::moda_incremental_query(data.frame(x = 1)), "")
})

test_that("apply_odk_labels translates select_one and select_multiple values", {
  df <- data.frame(
    sex = c("m", "f", NA, "x"),
    assets = c("tv radio", "radio", NA, "tv bike unknown"),
    stringsAsFactors = FALSE
  )
  label_map <- list(
    sex = c(m = "Male", f = "Female"),
    assets = c(tv = "Television", radio = "Radio", bike = "Bicycle")
  )
  out <- TargetWise:::apply_odk_labels(df, label_map)
  expect_equal(as.character(out$sex), c("Male", "Female", NA, "x"))
  # Labels joined by "; " (they can contain spaces), and one Yes/No column per choice.
  expect_equal(as.character(out$assets), c("Television; Radio", "Radio", NA, "Television; Bicycle; unknown"))
  expect_equal(out$assets_tv, c("Yes", "No", NA, "Yes"))
  expect_equal(out$assets_unknown, c("No", "No", NA, "Yes"))
})

test_that("read_import_file reads CSV and Parquet into plain data.frames", {
  tmp_csv <- tempfile(fileext = ".csv")
  df <- data.frame(id = 1:3, name = c("a", "b", ""), score = c(1.5, NA, 3), stringsAsFactors = FALSE)
  utils::write.csv(df, tmp_csv, row.names = FALSE)
  got <- TargetWise:::read_import_file(tmp_csv, "csv")
  expect_s3_class(got, "data.frame")
  expect_equal(nrow(got), 3)
  # write.csv quotes the empty string; fread keeps quoted "" as "" and turns
  # unquoted empties into NA. The app's missingness definition counts both.
  expect_true(is.na(got$name[3]) || identical(got$name[3], ""))

  skip_if_not_installed("nanoparquet")
  tmp_pq <- tempfile(fileext = ".parquet")
  nanoparquet::write_parquet(df, tmp_pq)
  got_pq <- TargetWise:::read_import_file(tmp_pq, "parquet")
  expect_equal(got_pq$id, 1:3)
  expect_equal(got_pq$score, df$score)

  expect_error(TargetWise:::read_import_file(tmp_csv, "txt"), "Unsupported")
})

test_that("autosave threshold defaults to 200 MB and honours the env override", {
  old <- Sys.getenv("TARGETWISE_AUTOSAVE_MAX_MB", unset = NA)
  on.exit(if (is.na(old)) Sys.unsetenv("TARGETWISE_AUTOSAVE_MAX_MB") else Sys.setenv(TARGETWISE_AUTOSAVE_MAX_MB = old))
  Sys.unsetenv("TARGETWISE_AUTOSAVE_MAX_MB")
  expect_equal(TargetWise:::autosave_max_bytes(), 200 * 1024^2)
  Sys.setenv(TARGETWISE_AUTOSAVE_MAX_MB = "50")
  expect_equal(TargetWise:::autosave_max_bytes(), 50 * 1024^2)
  Sys.setenv(TARGETWISE_AUTOSAVE_MAX_MB = "garbage")
  expect_equal(TargetWise:::autosave_max_bytes(), 200 * 1024^2)
})

test_that("session files are written uncompressed and still round-trip", {
  tmp_dir <- tempfile()
  old <- Sys.getenv("TARGETWISE_SESSION_DIR", unset = NA)
  Sys.setenv(TARGETWISE_SESSION_DIR = tmp_dir)
  on.exit({
    if (is.na(old)) Sys.unsetenv("TARGETWISE_SESSION_DIR") else Sys.setenv(TARGETWISE_SESSION_DIR = old)
    unlink(tmp_dir, recursive = TRUE)
  }, add = TRUE)

  df <- data.frame(id = 1:1000, v = rnorm(1000))
  f <- TargetWise:::save_session(df, list(unique_id = "id"), NULL, name = "perf")
  # gzip magic bytes are 1f 8b; an uncompressed RDS starts with "X\n"
  magic <- readBin(f, "raw", n = 2)
  expect_false(identical(magic, as.raw(c(0x1f, 0x8b))))
  expect_equal(TargetWise:::load_session("perf")$uploaded_df, df)
})

test_that("duplicate counting matches base R and survives awkward columns", {
  df <- data.frame(
    a = c(1, 2, 2, 3, 1),
    b = c("x", "y", "y", "z", "x"),
    stringsAsFactors = FALSE
  )
  # rows 3 and 5 repeat rows 2 and 1.
  expect_equal(TargetWise:::count_duplicate_rows(df), sum(duplicated(df)))
  expect_equal(TargetWise:::count_duplicate_rows(df), 2L)

  expect_equal(TargetWise:::count_duplicate_rows(df[0, ]), 0L)
  expect_equal(TargetWise:::count_duplicate_rows(NULL), 0L)

  # NAs are a value, not a wildcard: two all-NA rows are duplicates.
  na_df <- data.frame(a = c(NA, NA, 1), b = c(NA_character_, NA_character_, "x"),
                      stringsAsFactors = FALSE)
  expect_equal(TargetWise:::count_duplicate_rows(na_df), sum(duplicated(na_df)))

  # A list column (nested repeat group) is skipped instead of erroring.
  lst <- df
  lst$repeats <- I(list(1, 2, 3, 4, 5))
  expect_equal(TargetWise:::count_duplicate_rows(lst), 2L)
})

test_that("the kNN donor subsample is deterministic", {
  pool <- setdiff(seq_len(50000), 1:10)
  take <- function() {
    p <- pool
    p[unique(round(seq(1, length(p), length.out = TargetWise:::KNN_MAX_DONORS)))]
  }
  # Same correction, run twice, must pick the same donors -- an unseeded
  # sample() used to give different imputed values each time.
  expect_identical(take(), take())
  expect_lte(length(take()), TargetWise:::KNN_MAX_DONORS)
})
