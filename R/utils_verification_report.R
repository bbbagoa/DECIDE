#' Spot-check verification report (HTML)
#'
#' The back-check written up like the design report: what was sampled and
#' how, what came back from the field, how far the two rounds agree field by
#' field, the discordances themselves, and the method. One self-contained
#' HTML file (see `report_write_page()`).
#'
#' @param x List: `country_office`, `sample` (list: `method`, `n`,
#'   `population`, `seed`, `filters`), `source` (where the verification data
#'   came from), `n_verification`, `tolerance`, `comparison` (the output of
#'   `compare_verification()`).
#' @noRd
write_verification_report <- function(file, x, lang = "en") {
  r <- x$comparison
  pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  L <- character(0)
  add <- function(...) L <<- c(L, ...)

  add("# Verification report", "",
      "This report compares the households re-visited in the back-check with what was recorded the first time,",
      "field by field, so data quality can be judged and followed up.", "")
  if (!is.null(r)) add("## Key results", "", "@@AGREE@@", "")

  s <- x$sample %||% list()
  add("## 1. Sample", "",
      sprintf("- Method: **%s**", s$method %||% "n/a"),
      sprintf("- Households sampled: %s of %s in scope (%s)", format(s$n %||% NA, big.mark = ","),
              format(s$population %||% NA, big.mark = ","),
              if (isTRUE(s$population > 0)) pct(s$n / s$population) else "n/a"),
      sprintf("- Random seed: %s (the same seed and filters redraw the same households)", s$seed %||% "n/a"),
      sprintf("- Filters: %s", s$filters %||% "none"), "")

  add("## 2. Verification data", "")
  if (is.null(r)) {
    add("_No comparison has been run yet._", "")
  } else {
    add(sprintf("- Source: %s", x$source %||% "n/a"),
        sprintf("- Verification records: %s", format(x$n_verification %||% NA, big.mark = ",")),
        sprintf("- Matched on `%s`: **%s** households", r$key_col, format(r$matched_n, big.mark = ",")),
        sprintf("- Sampled but not re-visited: %s", format(r$only_original_n, big.mark = ",")),
        sprintf("- Re-visited but not in the sample: %s", format(r$only_verification_n, big.mark = ",")),
        sprintf("- Fields compared: %d; numeric tolerance: %s", length(r$cols), fmt5(x$tolerance %||% 0)), "")

    fs <- r$field_summary
    add("## 3. Agreement by field", "",
        "Share of matched households whose two answers agree, lowest first. At or above 95% is sound;",
        "90-95% calls for a look at how the question is asked; below 90% calls for follow-up with the enumerators.", "",
        "@@FIG:fields@@", "",
        md_table(data.frame(Field = fs$variable, Compared = fs$compared, Agree = fs$agree,
                            Disagree = fs$disagree, Agreement = vapply(fs$agreement_rate, pct, character(1)),
                            check.names = FALSE)), "")

    d <- r$discordances
    add("## 4. Discordances", "")
    if (!nrow(d)) {
      add("_Every compared answer agreed._", "")
    } else {
      add(sprintf("%s households (%s of those matched) have at least one discordance; %s answers differ in all.",
                  format(r$records_with_discordance, big.mark = ","), pct(r$records_with_discordance / max(1, r$matched_n)),
                  format(nrow(d), big.mark = ",")), "",
          if (nrow(d) > 300) "The first 300 are listed; the full list is in the Excel export." else NULL, "",
          md_table(stats::setNames(utils::head(d, 300), c("Household", "Field", "First round", "Back-check"))), "")
    }
  }

  add("## 5. Method", "",
      "### Sampling", "",
      paste("**Simple random**: every household in scope has the same chance of being drawn.",
            "**Systematic**: every k-th household from a random start, which spreads the sample across the list.",
            "**PPS**: probability proportional to household size (or weight), so larger households are more likely to be drawn.",
            "The draw is seeded, so the list can be reproduced."), "",
      "### Comparison", "",
      paste("The two rounds are matched on the household identifier; a household present on one side only is counted but not compared.",
            "Text answers are compared after trimming spaces and ignoring case; numbers agree when they differ by no more than the tolerance;",
            "a missing answer on both sides counts as agreement, on one side only as a discordance."), "")

  plots <- list()
  if (!is.null(r) && nrow(r$field_summary)) {
    fs <- r$field_summary
    a <- round(100 * fs$agreement_rate, 1)
    band <- ifelse(a >= 95, "ok", ifelse(a >= 90, "warn", "bad"))
    fd <- data.frame(field = fs$variable,
                     ok = ifelse(band == "ok", a, 0), warn = ifelse(band == "warn", a, 0), bad = ifelse(band == "bad", a, 0))
    lab <- vapply(c("95% or more", "90-95%", "Below 90%"), function(t) i18n_lookup(t, lang), character(1))
    names(fd)[2:4] <- lab
    plots$fields <- rp_hbars(fd, stats::setNames(c("#3f7e44", "#d08a00", "#c5192d"), lab),
                             i18n_lookup("Agreement (%)", lang), stacked = TRUE) |>
      billboarder::bb_y_axis(min = 0, max = 100, padding = list(top = 0, bottom = 0),
                             label = rp_axis_label(i18n_lookup("Agreement (%)", lang), rotated = TRUE))
  }

  report_write_page(
    file, paste(L, collapse = "\n"), plots,
    captions = c(fields = "Agreement by field"), lang = lang,
    title = "Verification report", record = "Spot-check back-check record",
    meta = c("Country office" = x$country_office %||% "",
             "Generated" = format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Matched" = if (is.null(r)) "" else format(r$matched_n, big.mark = ",")),
    footer = "This record documents the back-check so data quality can be reviewed and followed up.",
    blocks = list("@@AGREE@@" = verification_cards(r, lang)))
}

#' Headline cards of the back-check
#' @noRd
verification_cards <- function(r, lang = "en") {
  if (is.null(r)) return("")
  tr <- function(t) htmltools::htmlEscape(i18n_lookup(t, lang))
  st <- c(ok = "Sound", warn = "Worth a look", bad = "Follow up", na = "Not available")
  ag <- r$overall_agreement
  ag_band <- if (is.na(ag)) "na" else if (ag >= .95) "ok" else if (ag >= .90) "warn" else "bad"
  disc <- r$records_with_discordance / max(1, r$matched_n)
  d_band <- if (is.na(disc)) "na" else if (disc <= .05) "ok" else if (disc <= .15) "warn" else "bad"
  ico_ok <- '<svg viewBox="0 0 16 16"><path d="M3 8.5 6.5 12 13 4.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  ico_x <- '<svg viewBox="0 0 16 16"><path d="M4 4l8 8M12 4l-8 8" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>'
  paste0('<div class="err-cards">',
    report_gauge_card(tr("Overall agreement"), ag, ag_band, tr(st[[ag_band]]),
                      tr("Answers that match between the two rounds"),
                      sprintf("<strong>%s</strong> %s", format(sum(r$field_summary$compared), big.mark = ","), tr("answers compared")),
                      ico_ok, zones = c(bad = .90, warn = .95, ok = 1), max = 1, min = .5),
    report_gauge_card(tr("Households with a discordance"), disc, d_band, tr(st[[d_band]]),
                      tr("Matched households with at least one answer that differs"),
                      sprintf("<strong>%s</strong> %s <strong>%s</strong> %s", format(r$records_with_discordance, big.mark = ","),
                              tr("of"), format(r$matched_n, big.mark = ","), tr("matched households")),
                      ico_x, zones = c(ok = .05, warn = .15, bad = .5), max = .5),
    '</div>')
}
