# Test data for react/dev/test_dq.R: the demo registration data with an
# enumerator (enum_03 interviews in under 10 minutes), interview start and
# end times, gaps in the head's age, status and children, and 5 records registered twice (a new id, the rest identical:
# the setup refuses repeated ids).
write_dq_test_data <- function(file) {
  set.seed(1)
  d <- utils::read.csv(file.path(tw_root, "inst/extdata/registration_demo.csv"), check.names = FALSE)
  d$enumerator <- sprintf("enum_%02d", sample(1:12, nrow(d), TRUE))
  st <- as.POSIXct(paste(d$SvyDate, "09:00:00"), tz = "UTC") + sample(0:20000, nrow(d), TRUE)
  dur <- ifelse(d$enumerator == "enum_03", stats::runif(nrow(d), 7, 10), stats::runif(nrow(d), 25, 50))
  d$start <- format(st, "%Y-%m-%dT%H:%M:%S")
  d$end <- format(st + dur * 60, "%Y-%m-%dT%H:%M:%S")
  # gaps that go together: about 6% miss the age, most of them the status too
  gap <- stats::runif(nrow(d)) < 0.06
  d$HHHAge[gap] <- NA
  d$HHStatus[gap & stats::runif(nrow(d)) < 0.7] <- ""
  d$HHSize24M[stats::runif(nrow(d)) < 0.03] <- NA
  d$HHSize[100:105] <- 99   # a "don't know" code: the outlier insights offer to select them
  twice <- d[1:5, ]
  twice$instanceID <- sprintf("reg:dup%02d", 1:5)
  utils::write.csv(rbind(d, twice), file, row.names = FALSE)
}
