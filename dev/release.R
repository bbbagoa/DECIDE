# Build the distributable artefacts for a release.
#
# Run from the package root, in a fresh R session, on Windows with R matching
# the users' R version (binaries are built for this R version):
#
#   source("dev/release.R")
#   release_build()                      # both artefacts below
#   release_build(include_r = TRUE)      # also bundle the R installer
#
# Produces, under dist/:
#
# 1. dist/repo/  A CRAN-like repository with the source package and the
#    Windows binary of TargetWise only. Publish its contents anywhere
#    users can reach over HTTP (e.g. a public GitHub Pages repository holding
#    only this folder); then anyone installs with
#      install.packages("TargetWise",
#                       repos = c("<url>", "https://cloud.r-project.org"))
#    and the app's update check reads <url>/src/contrib/PACKAGES.
#
# 2. dist/TargetWise_<version>_offline_windows_R<x.y>.zip
#    Everything needed to install with NO internet and NO GitHub account:
#    the package and every dependency as Windows binaries in a local
#    repository, plus install.R and a short READ-ME. Share it by USB, email
#    or SharePoint.

release_build <- function(include_r = FALSE, cran = "https://cloud.r-project.org",
                          optional = c("ranger", "xgboost")) {
  stopifnot(file.exists("DESCRIPTION"))
  if (.Platform$OS.type != "windows") stop("Build the offline bundle on Windows.", call. = FALSE)
  desc <- read.dcf("DESCRIPTION")
  pkg <- desc[1, "Package"]; ver <- desc[1, "Version"]
  rver <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  dist <- normalizePath("dist", mustWork = FALSE)
  unlink(dist, recursive = TRUE); dir.create(dist)

  # -- 1. the package itself: source and Windows binary ----------------------
  src_dir <- file.path(dist, "repo", "src", "contrib")
  bin_dir <- file.path(dist, "repo", "bin", "windows", "contrib", rver)
  dir.create(src_dir, recursive = TRUE); dir.create(bin_dir, recursive = TRUE)
  message("Building ", pkg, " ", ver, " ...")
  src <- pkgbuild::build(".", dest_path = src_dir, vignettes = FALSE, quiet = TRUE)
  bin <- pkgbuild::build(".", dest_path = bin_dir, binary = TRUE, vignettes = FALSE, quiet = TRUE)
  tools::write_PACKAGES(src_dir, type = "source")
  tools::write_PACKAGES(bin_dir, type = "win.binary")

  # -- 2. offline bundle: the package plus every dependency ------------------
  bundle <- file.path(dist, sprintf("%s_%s_offline_windows_R%s", pkg, ver, rver))
  off_bin <- file.path(bundle, "repo", "bin", "windows", "contrib", rver)
  dir.create(off_bin, recursive = TRUE)
  file.copy(bin, off_bin)

  imports <- trimws(sub("[(].*$", "", strsplit(desc[1, "Imports"], ",")[[1]]))
  db <- utils::available.packages(repos = cran, type = "win.binary")
  base <- rownames(utils::installed.packages(priority = "base"))
  deps <- tools::package_dependencies(c(imports, optional), db = db, recursive = TRUE,
                                      which = c("Depends", "Imports", "LinkingTo"))
  need <- setdiff(unique(c(imports, optional, unlist(deps))), c(base, pkg))
  need <- intersect(need, rownames(db))
  message("Downloading ", length(need), " dependency binaries ...")
  # Some binaries (sf, terra) are 30+ MB: R's default 60 s timeout cut them
  # off and left an incomplete bundle. Allow time, retry once, then refuse to
  # ship a bundle that would fail offline.
  old_to <- options(timeout = max(1800, getOption("timeout"))); on.exit(options(old_to), add = TRUE)
  got <- function() sub("_.*$", "", list.files(off_bin, "[.]zip$"))
  utils::download.packages(need, destdir = off_bin, repos = cran, type = "win.binary", quiet = TRUE)
  miss <- setdiff(need, got())
  if (length(miss)) utils::download.packages(miss, destdir = off_bin, repos = cran, type = "win.binary", quiet = TRUE)
  miss <- setdiff(need, got())
  if (length(miss)) stop("Could not download: ", paste(miss, collapse = ", "),
                         ". Check the connection and run release_build() again.", call. = FALSE)
  tools::write_PACKAGES(off_bin, type = "win.binary")

  writeLines(c(
    "# Install TargetWise from this folder -- no internet needed.",
    "# In R (or RStudio): File > Change dir... to this folder, then run",
    "#   source(\"install.R\")",
    "here <- normalizePath(getwd(), winslash = \"/\")",
    "if (!file.exists(file.path(here, \"repo\"))) stop(\"Run this from the unzipped bundle folder.\")",
    "repo <- paste0(\"file:///\", here, \"/repo\")",
    sprintf("if (getRversion() < \"%s\" || getRversion() >= \"%s\")", rver,
            paste(R.version$major, as.integer(strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1]) + 1, sep = ".")),
    sprintf("  warning(\"This bundle was built for R %s.x; you have R \", getRversion(), \". Install R %s if installation fails.\")", rver, rver),
    "install.packages(\"TargetWise\", repos = repo, type = \"win.binary\",",
    "                 dependencies = c(\"Depends\", \"Imports\", \"LinkingTo\"))",
    sprintf("install.packages(c(%s), repos = repo, type = \"win.binary\")",
            paste0("\"", optional, "\"", collapse = ", ")),
    "message(\"Done. Start the app with: TargetWise::run_app()\")"
  ), file.path(bundle, "install.R"))

  writeLines(c(
    sprintf("TargetWise %s -- offline installer for Windows (R %s)", ver, rver),
    "",
    "Nothing here needs an internet connection or a GitHub account.",
    "",
    sprintf("1. If R %s is not installed, install it first%s.", rver,
            if (include_r) " with the R installer in this folder" else " (https://cran.r-project.org)"),
    "2. Unzip this folder anywhere, open R (or RStudio), and set the working",
    "   directory to it: in R, File > Change dir...; in RStudio, Session > Set",
    "   Working Directory > Choose Directory.",
    "3. Run:   source(\"install.R\")",
    "4. Start the app any time with:   TargetWise::run_app()",
    "",
    "To update, install a newer bundle the same way; your saved sessions are kept."
  ), file.path(bundle, "READ-ME.txt"))

  if (include_r) {
    full <- sprintf("%s.%s", R.version$major, R.version$minor)
    url <- sprintf("https://cloud.r-project.org/bin/windows/base/old/%s/R-%s-win.exe", full, full)
    message("Downloading the R ", full, " installer ...")
    utils::download.file(url, file.path(bundle, sprintf("R-%s-win.exe", full)), mode = "wb", quiet = TRUE)
  }

  zipfile <- paste0(bundle, ".zip")
  zip::zipr(zipfile, bundle)   # the zip package: no external zip program needed
  message("\nRelease ", ver, " built:",
          "\n  online repository : ", file.path(dist, "repo"),
          "\n  offline bundle    : ", zipfile, " (",
          round(file.info(zipfile)$size / 1024^2), " MB)")
  invisible(list(repo = file.path(dist, "repo"), bundle = zipfile))
}
