#' Formatted text for the reports
#'
#' A small editor (bold, italic, underline, strike, headings, size, text and
#' highlight colours, lists, alignment, links, clear formatting) that returns
#' HTML. `www/richtext.js` holds the toolbar and the Shiny input binding and
#' cleans pasted markup; `rich_html()` cleans it again on the server before
#' it goes into a report, since a report file travels.
#' @name rich_text
#' @noRd
NULL

#' The editor: a toolbar over an editable box
#'
#' @param id Input id (namespaced by the caller), or NULL for an editor that
#'   reports through `send` instead (editors drawn in a renderUI list).
#' @param send,item With `id = NULL`: the input that receives
#'   `list(id = item, text = html)` when the text changes.
#' @noRd
rich_text_input <- function(id = NULL, label = NULL, value = "", placeholder = "", rows = 3,
                            send = NULL, item = NULL, compact = FALSE) {
  btn <- function(cmd, icon_name, title, arg = NULL)
    tags$button(type = "button", class = "tw-rt-btn", `data-cmd` = cmd, `data-arg` = arg, title = title,
                `aria-label` = title, bsicons::bs_icon(icon_name))
  sep <- tags$span(class = "tw-rt-sep")
  toolbar <- tags$div(
    class = "tw-rt-toolbar", role = "toolbar",
    tags$select(class = "tw-rt-select", `data-cmd` = "formatBlock", title = "Paragraph style",
                tags$option(value = "p", "Paragraph"), tags$option(value = "h3", "Heading"),
                tags$option(value = "h4", "Subheading"), tags$option(value = "blockquote", "Quote")),
    tags$select(class = "tw-rt-select", `data-cmd` = "fontSize", title = "Text size",
                tags$option(value = "2", "Small"), tags$option(value = "3", selected = NA, "Medium"),
                tags$option(value = "5", "Large"), tags$option(value = "6", "Huge")),
    sep,
    btn("bold", "type-bold", "Bold"), btn("italic", "type-italic", "Italic"),
    btn("underline", "type-underline", "Underline"), btn("strikeThrough", "type-strikethrough", "Strikethrough"),
    sep,
    tags$label(class = "tw-rt-color", title = "Text colour", bsicons::bs_icon("fonts"),
               tags$input(type = "color", `data-cmd` = "foreColor", value = "#007DBC")),
    tags$label(class = "tw-rt-color", title = "Highlight", bsicons::bs_icon("highlighter"),
               tags$input(type = "color", `data-cmd` = "hiliteColor", value = "#fff3bf")),
    sep,
    btn("insertUnorderedList", "list-ul", "Bulleted list"), btn("insertOrderedList", "list-ol", "Numbered list"),
    btn("justifyLeft", "text-left", "Align left"), btn("justifyCenter", "text-center", "Centre"),
    btn("justifyRight", "text-right", "Align right"),
    sep,
    btn("createLink", "link-45deg", "Link"), btn("removeFormat", "eraser", "Clear formatting"))
  tags$div(
    class = paste("form-group shiny-input-container tw-rt", if (compact) "tw-rt-compact"),
    style = "width: 100%;",
    if (!is.null(label)) tags$label(class = "control-label", `for` = id, label),
    tags$div(class = "tw-rt-frame", toolbar,
             tags$div(id = id, class = if (!is.null(id)) "tw-rich" else "tw-rich tw-rich-send",
                      contenteditable = "true", role = "textbox", `aria-multiline` = "true",
                      `aria-label` = label %||% placeholder, `data-placeholder` = placeholder,
                      `data-send` = send, `data-item` = item,
                      style = sprintf("min-height: %.1frem;", 1.6 * rows + 0.9),
                      HTML(rich_html(value, empty = "")))))
}

#' Set an editor's text from the server
#' @noRd
update_rich_text <- function(session, id, value = "") {
  session$sendInputMessage(id, list(value = rich_html(value, empty = "")))
}

#' Clean HTML from the editor for a report
#'
#' Keeps formatting tags and safe inline styles; drops scripts, event
#' handlers, other attributes and non-http links. Plain text (older sessions,
#' pasted text) is escaped with its line breaks kept.
#' @noRd
rich_html <- function(x, empty = "") {
  x <- paste(as.character(x %||% ""), collapse = "\n")
  if (!nzchar(trimws(gsub("<[^>]*>|&nbsp;", "", x)))) return(empty)
  if (!grepl("<[a-zA-Z/][^>]*>", x)) {
    paras <- strsplit(trimws(x), "\n[ \t]*\n")[[1]]
    return(paste0("<p>", gsub("\n", "<br>", htmltools::htmlEscape(paras), fixed = TRUE), "</p>", collapse = ""))
  }
  # Whole elements whose content must go too.
  x <- gsub("<(script|style|iframe|object|embed|template|noscript|svg|math|textarea|select)\\b.*?</\\1\\s*>", "",
            x, ignore.case = TRUE, perl = TRUE)
  x <- gsub("<!--.*?-->", "", x, perl = TRUE)
  keep <- c("p", "div", "br", "b", "strong", "i", "em", "u", "s", "strike", "del", "sub", "sup",
            "h3", "h4", "blockquote", "ul", "ol", "li", "span", "font", "a")
  font_size <- c("1" = "0.75em", "2" = "0.85em", "3" = "1em", "4" = "1.15em", "5" = "1.35em", "6" = "1.7em", "7" = "2.2em")
  safe_style <- function(st) {
    decl <- trimws(strsplit(st, ";", fixed = TRUE)[[1]])
    decl <- decl[grepl("^(color|background-color|text-align|font-size|font-weight|font-style|text-decoration(-line)?)\\s*:", decl, ignore.case = TRUE)]
    # Values: colours, keywords, sizes; nothing that can load or run anything.
    decl <- decl[grepl("^[^:]+:\\s*[-#(),.%a-zA-Z0-9 ]+$", decl) & !grepl("url|expression|javascript|@|\\\\", decl, ignore.case = TRUE)]
    paste(decl, collapse = "; ")
  }
  attr_val <- function(tag, name) {
    m <- regmatches(tag, regexec(sprintf("\\s%s\\s*=\\s*(\"([^\"]*)\"|'([^']*)'|([^\\s>]+))", name), tag, ignore.case = TRUE, perl = TRUE))[[1]]
    if (!length(m)) return(NULL)
    v <- m[3:5]; v <- v[nzchar(v)]
    if (length(v)) htmltools::htmlEscape(gsub("&quot;", "\"", gsub("&amp;", "&", v[1], fixed = TRUE), fixed = TRUE), attribute = TRUE) else ""
  }
  clean_tag <- function(tag) {
    m <- regmatches(tag, regexec("^<\\s*(/?)\\s*([a-zA-Z0-9]+)", tag))[[1]]
    if (!length(m)) return("")
    close <- nzchar(m[2]); name <- tolower(m[3])
    if (!name %in% keep) return("")
    out_name <- if (name == "font") "span" else name
    if (close) return(sprintf("</%s>", out_name))
    if (name == "br") return("<br>")
    st <- safe_style(attr_val(tag, "style") %||% "")
    if (name == "font") {
      col <- attr_val(tag, "color"); sz <- attr_val(tag, "size")
      if (!is.null(col) && grepl("^#?[a-zA-Z0-9]+$", col)) st <- paste(c(if (nzchar(st)) st, paste0("color: ", col)), collapse = "; ")
      if (!is.null(sz) && sz %in% names(font_size)) st <- paste(c(if (nzchar(st)) st, paste0("font-size: ", font_size[[sz]])), collapse = "; ")
    }
    al <- attr_val(tag, "align")
    if (!is.null(al) && tolower(al) %in% c("left", "center", "right", "justify")) st <- paste(c(if (nzchar(st)) st, paste0("text-align: ", tolower(al))), collapse = "; ")
    href <- if (name == "a") attr_val(tag, "href") else NULL
    href_ok <- !is.null(href) && grepl("^(https?:|mailto:)", href, ignore.case = TRUE)
    paste0("<", out_name,
           if (nzchar(st)) sprintf(' style="%s"', htmltools::htmlEscape(st, attribute = TRUE)),
           if (href_ok) sprintf(' href="%s" target="_blank" rel="noopener noreferrer"', href), ">")
  }
  tags_at <- gregexpr("<[^<>]*>", x)[[1]]
  if (tags_at[1] == -1) return(htmltools::htmlEscape(x))
  starts <- as.integer(tags_at); ends <- starts + attr(tags_at, "match.length") - 1
  text_between <- function(a, b) {
    t <- if (b >= a) substr(x, a, b) else ""
    # Stray angle brackets could open a tag once the block sits in a page.
    t <- gsub("<", "&lt;", gsub(">", "&gt;", t, fixed = TRUE), fixed = TRUE)
    gsub("&(?![a-zA-Z]+;|#[0-9]+;|#x[0-9a-fA-F]+;)", "&amp;", t, perl = TRUE)
  }
  out <- character(0); pos <- 1
  for (k in seq_along(starts)) {
    out <- c(out, text_between(pos, starts[k] - 1), clean_tag(substr(x, starts[k], ends[k])))
    pos <- ends[k] + 1
  }
  paste(c(out, text_between(pos, nchar(x))), collapse = "")
}

#' The editor's text without formatting (Excel cells, audit trail)
#' @noRd
rich_text <- function(x) {
  x <- paste(as.character(x %||% ""), collapse = "\n")
  if (!grepl("<[a-zA-Z/][^>]*>", x)) return(trimws(x))
  x <- gsub("<(br|/p|/div|/li|/h[1-6]|/blockquote)[^>]*>", "\n", x, ignore.case = TRUE)
  x <- gsub("<li[^>]*>", "- ", x, ignore.case = TRUE)
  x <- gsub("<[^>]*>", "", x)
  ent <- c("&nbsp;" = " ", "&lt;" = "<", "&gt;" = ">", "&quot;" = "\"", "&#39;" = "'", "&amp;" = "&")
  for (e in names(ent)) x <- gsub(e, ent[[e]], x, fixed = TRUE)
  trimws(gsub("\n{3,}", "\n\n", gsub("[ \t]+\n", "\n", x)))
}
