# These tests exercise the actual encrypt_session()/decrypt_session() pipeline.
# The companion test-session-manager.R only does a manual saveRDS/readRDS and
# therefore bypasses the sodium encryption code path entirely.

with_session_dir <- function(code) {
  tmp <- tempfile()
  dir.create(tmp, recursive = TRUE)
  old <- Sys.getenv("DECIDE_SESSION_DIR")
  old_pw <- Sys.getenv("DECIDE_SESSION_PASSPHRASE")
  Sys.setenv(
    DECIDE_SESSION_DIR = tmp,
    DECIDE_SESSION_PASSPHRASE = ""
  )
  on.exit({
    Sys.setenv(
      DECIDE_SESSION_DIR = old,
      DECIDE_SESSION_PASSPHRASE = old_pw
    )
  }, add = TRUE)
  force(code)
}

test_that("encrypt/decrypt round-trip returns an identical object (passphrase mode)", {
  with_session_dir({
    state <- list(
      uploaded_df = data.frame(id = 1:3, v = letters[1:3], stringsAsFactors = FALSE),
      user_setup = list(admin1 = "adm1", date = "dt"),
      saved_at = Sys.time()
    )
    cipher <- encrypt_session(state, passphrase = "my-test-passphrase")
    expect_type(cipher, "raw")
    expect_false(identical(cipher, serialize(state, NULL))) # actually encrypted

    restored <- decrypt_session(cipher, passphrase = "my-test-passphrase")
    expect_equal(restored, state)
  })
})

test_that("the wrong passphrase fails to decrypt", {
  with_session_dir({
    cipher <- encrypt_session(list(a = 1), passphrase = "correct")
    expect_error(decrypt_session(cipher, passphrase = "wrong"))
  })
})

test_that("per-install key is generated and reused", {
  with_session_dir({
    expect_false(file.exists(get_session_key_file()))

    k1 <- get_or_create_session_key()
    expect_true(file.exists(get_session_key_file()))
    expect_length(k1, 32L)

    # Second call reads the same key back rather than regenerating it
    k2 <- get_or_create_session_key()
    expect_identical(k2, k1)
  })
})

test_that("per-install key encrypt/decrypt round-trip works without a passphrase", {
  with_session_dir({
    # No passphrase configured -> derive_session_key() uses the key file
    state <- list(x = 1:5, label = "no-passphrase")
    cipher <- encrypt_session(state)
    expect_equal(decrypt_session(cipher), state)
  })
})

test_that("derive_session_key prefers the passphrase when one is set", {
  with_session_dir({
    pw_key <- derive_session_key("explicit")
    expect_identical(pw_key, sodium::hash(charToRaw("explicit"), size = 32L))
  })
})
