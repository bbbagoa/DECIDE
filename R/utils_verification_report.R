#' Spot-check verification report (HTML)
#'
#' The back-check written up like the design report: headline results and
#' insights first (weakest field, enumerator and area, households to
#' re-check), then the sample, the agreement by field (only the fields that
#' need attention are tabled; the sound ones are listed in a line), where the
#' discordances concentrate, what changes between the rounds, and the method.
#' Long lists are capped; the full detail is in the Excel export. One
#' self-contained HTML file (see `report_write_page()`).
#'
#' @param x List: `country_office`, `sample` (list: `method`, `n`,
#'   `population`, `seed`, `filters`), `source` (where the verification data
#'   came from), `n_verification`, `tolerance`, `comparison` (the output of
#'   `compare_verification()`), `insights` (the output of
#'   `verification_insights()`, optional).
#' @noRd
write_verification_report <- function(file, x, lang = "en") {
  r <- x$comparison
  ins <- x$insights
  pct <- function(v) if (is.null(v) || length(v) == 0 || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  pcts <- function(v) ifelse(is.na(v), "n/a", sprintf("%.1f%%", 100 * v))
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  n_sec <- 0
  sec <- function(title) { n_sec <<- n_sec + 1; add(sprintf("## %d. %s", n_sec, title), "") }

  add("# Verification report", "",
      "This report compares the households re-visited in the back-check with what was recorded the first time,",
      "field by field, so data quality can be judged and followed up.", "")
  if (!is.null(r)) add("## Key results", "", "@@AGREE@@", "", "@@TILES@@", "")

  s <- x$sample %||% list()
  sec("Sample")
  add(sprintf("- Method: **%s**", s$method %||% "n/a"),
      sprintf("- Households sampled: %s of %s in scope (%s)", format(s$n %||% NA, big.mark = ","),
              format(s$population %||% NA, big.mark = ","),
              if (isTRUE(s$population > 0)) pct(s$n / s$population) else "n/a"),
      sprintf("- Random seed: %s (the same seed and filters redraw the same households)", s$seed %||% "n/a"),
      sprintf("- Filters: %s", s$filters %||% "none"), "")

  sec("Verification data")
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
    sec("Agreement by field")
    low <- fs[!is.na(fs$agreement_rate) & fs$agreement_rate < 0.95, , drop = FALSE]
    sound <- fs$variable[!is.na(fs$agreement_rate) & fs$agreement_rate >= 0.95]
    add("Share of matched households whose two answers agree. At or above 95% is sound;",
        "90-95% calls for a look at how the question is asked; below 90% calls for follow-up with the enumerators.", "",
        "@@FIG:fields@@", "",
        if (nrow(fs) > 15) sprintf("_The chart shows the 15 fields with the lowest agreement, of %d compared._", nrow(fs)) else NULL, "")
    if (nrow(low)) {
      add("### Fields that need attention", "",
          md_table(data.frame(Field = low$variable, Compared = low$compared, Disagree = low$disagree,
                              Agreement = pcts(low$agreement_rate),
                              Reading = ifelse(low$agreement_rate < 0.90, "Follow up with the enumerators", "Check how the question is asked"),
                              check.names = FALSE)), "")
    } else {
      add("_Every field agrees in 95% of households or more._", "")
    }
    if (length(sound)) add(sprintf("**Sound (95%% or more), %d field%s:** %s.", length(sound), if (length(sound) == 1) "" else "s",
                               paste(sound, collapse = ", ")), "")

    if (!is.null(ins) && length(ins$by_group)) {
      sec("Where the discordances concentrate")
      add("Agreement over all the answers compared for the households of each enumerator or area, lowest first.", "")
      for (lab in names(ins$by_group)) {
        g <- ins$by_group[[lab]]
        shown <- utils::head(g, 10)
        add(sprintf("### By %s", tolower(lab)), "",
            md_table(stats::setNames(data.frame(shown$group, shown$households, shown$with_discordance, pcts(shown$agreement)),
                                     c(lab, "Households", "With a discordance", "Agreement"))),
            if (nrow(g) > 10) sprintf("_The 10 lowest of %d; the full list is in the Excel export._", nrow(g)) else NULL, "")
      }
    }

    d <- r$discordances
    sec("What changes between the rounds")
    if (!nrow(d)) {
      add("_Every compared answer agreed._", "")
    } else {
      add(sprintf("%s households (%s of those matched) have at least one discordance; %s answers differ in all.",
                  format(r$records_with_discordance, big.mark = ","), pct(r$records_with_discordance / max(1, r$matched_n)),
                  format(nrow(d), big.mark = ",")), "")
      if (!is.null(ins$patterns) && nrow(ins$patterns)) {
        add("### The most frequent changes", "",
            "The same change seen many times points to a question read or coded differently, rather than to one household.", "",
            md_table(stats::setNames(ins$patterns, c("Field", "First round", "Back-check", "Households"))), "")
      }
      if (!is.null(ins$direction) && nrow(ins$direction)) {
        dd <- ins$direction
        add("### Number fields: which way the answers move", "",
            "When the back-check is mostly higher (or mostly lower), the first round was systematically under- (or over-) reported.", "",
            md_table(data.frame(Field = dd$field, `Back-check higher` = dd$higher, `Back-check lower` = dd$lower,
                                `Mean gap` = round(dd$gap, 2), check.names = FALSE)), "")
      }
      if (!is.null(ins$households) && nrow(ins$households)) {
        hh <- ins$households
        add("### Households to re-check first", "",
            md_table(data.frame(Household = hh$household, `Fields that differ` = hh$fields, Which = hh$which,
                                check.names = FALSE)),
            if (r$records_with_discordance > nrow(hh)) "_The full list of discordances is in the Excel export._" else NULL, "")
      }
    }
  }

  if (length(x$variables_md)) add(x$variables_md)
  sec("Method")
  add("### Sampling", "",
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
    fs <- utils::head(r$field_summary[order(r$field_summary$agreement_rate), , drop = FALSE], 15)
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
    captions = c(fields = if (!is.null(r) && nrow(r$field_summary) > 15) "Agreement by field (the 15 lowest)" else "Agreement by field"),
    lang = lang,
    title = "Verification report", record = "Spot-check back-check record",
    meta = c("Country office" = x$country_office %||% "",
             "Generated" = fmt_datetime(),
             "Matched" = if (is.null(r)) "" else format(r$matched_n, big.mark = ",")),
    footer = "This record documents the back-check so data quality can be reviewed and followed up.",
    blocks = list("@@AGREE@@" = verification_cards(r, lang),
                  "@@TILES@@" = profile_tiles(verification_tiles(r, ins), lang)))
}

#' Insight tiles of the back-check: weakest field, fields to follow up,
#' lowest enumerator and area, households with several discordances
#' @noRd
verification_tiles <- function(r, ins) {
  if (is.null(r) || !nrow(r$field_summary)) return(list())
  fs <- r$field_summary
  tile <- function(icon, value, label, sub) list(icon = icon, value = value, label = label, sub = sub)
  w <- fs[which.min(fs$agreement_rate), ]
  tiles <- list(
    tile("field", sprintf("%.1f%%", 100 * w$agreement_rate), "Weakest field", w$variable),
    tile("flag", as.character(sum(fs$agreement_rate < 0.90, na.rm = TRUE)), "Fields to follow up",
         sprintf("below 90%% agreement, of %d compared", nrow(fs))))
  for (lab in names(ins$by_group %||% list())) {
    g <- ins$by_group[[lab]]
    g <- g[g$households >= 2, , drop = FALSE]   # one household says little
    if (!nrow(g) || nrow(ins$by_group[[lab]]) < 2) next
    tiles[[length(tiles) + 1]] <- tile(if (identical(lab, "Enumerator")) "person" else "pin",
                                       sprintf("%.1f%%", 100 * g$agreement[1]), paste("Lowest", tolower(lab)),
                                       sprintf("%s (%d households)", g$group[1], g$households[1]))
  }
  if (nrow(r$discordances)) {
    k <- sum(table(unique(r$discordances[, c("key", "variable")])$key) >= 3)
    tiles[[length(tiles) + 1]] <- tile("shelter", as.character(k), "Households with 3+ discordances",
                                       "to re-check first")
  }
  tiles
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
