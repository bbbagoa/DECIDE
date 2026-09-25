test_that("formatted report text keeps formatting and loses anything that can run", {
  rich_html <- TargetWise:::rich_html
  expect_equal(rich_html(""), "")
  expect_equal(rich_html("<p><br></p>"), "")
  # plain text from older sessions: escaped, line breaks kept
  expect_equal(rich_html("a < b\nnext\n\nsecond"), "<p>a &lt; b<br>next</p><p>second</p>")
  keep <- rich_html('<p style="text-align: center"><b>Bold</b> <span style="color: rgb(197, 25, 45); background-color: #fff3bf">red</span></p><ul><li>one</li></ul><h3>T</h3>')
  expect_match(keep, '<p style="text-align: center"><b>Bold</b>', fixed = TRUE)
  expect_match(keep, 'style="color: rgb(197, 25, 45); background-color: #fff3bf"', fixed = TRUE)
  expect_match(keep, "<ul><li>one</li></ul><h3>T</h3>", fixed = TRUE)
  # font tags from execCommand become spans
  expect_equal(rich_html('<font color="#0a6eb4" size="5">x</font>'), '<span style="color: #0a6eb4; font-size: 1.35em">x</span>')
  bad <- rich_html(paste0('<p onclick="alert(1)">ok</p><script>alert(2)</script><img src=x onerror=alert(3)>',
                          '<a href="javascript:alert(4)">l</a><a href="https://wfp.org" onmouseover="x()">w</a>',
                          '<span style="background: url(http://x)">u</span><iframe src="x"></iframe><style>p{}</style>'))
  expect_false(grepl("alert|script|onerror|onclick|onmouseover|javascript|iframe|img|url\\(|<style", bad))
  expect_match(bad, '<a href="https://wfp.org" target="_blank" rel="noopener noreferrer">w</a>', fixed = TRUE)
  expect_match(bad, "<p>ok</p>", fixed = TRUE)
  # a stray bracket cannot open a tag once the block sits in a page
  expect_false(grepl("<img", rich_html("<b>x</b> <img src=x onerror=alert(1)")))
})

test_that("formatted text reads as plain text for Excel and the audit trail", {
  rich_text <- TargetWise:::rich_text
  expect_equal(rich_text("<p>One &amp; <b>two</b></p><ul><li>a</li><li>b</li></ul>"), "One & two\n- a\n- b")
  expect_equal(rich_text("plain"), "plain")
  expect_equal(rich_text(NULL), "")
})

test_that("report items draw in the chosen chart style", {
  tm <- function(f) utils::getFromNamespace(f, "TargetWise")
  d <- data.frame(x = c("A", "B", "C"), group = "All", value = c(5, 3, 2), n = c(5, 3, 2))
  for (st in c("auto", "bar", "column", "donut", "pie", "line", "area")) {
    b <- tm("monitoring_item_chart")(list(data = d, spec = list(type = "count", x = "v", style = st)))
    expect_s3_class(b, "billboarder")
  }
  pie <- tm("monitoring_item_chart")(list(data = d, spec = list(type = "count", style = "pie")))
  expect_equal(pie$x$bb_opts$data$type, "pie")
  expect_equal(tm("chart_style")(list(type = "trend")), "line")
  expect_equal(tm("chart_style")(list(type = "count", style = "nonsense")), "bar")
  expect_null(tm("chart_pie_note")(list(type = "count", style = "pie")))
  expect_match(tm("chart_pie_note")(list(type = "mean", style = "donut")), "parts of a whole")
  g <- rbind(d, transform(d, group = "Other"))
  expect_equal(tm("chart_pie_data")(g)$n, c(10, 6, 4))
})
