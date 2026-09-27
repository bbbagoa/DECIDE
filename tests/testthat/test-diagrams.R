test_that("tree_structure and tree_svg draw every node of an rpart tree", {
  skip_if_not_installed("rpart")
  set.seed(1)
  d <- data.frame(a = rbinom(400, 1, .5), b = rbinom(400, 1, .5))
  d$y <- factor(as.integer(d$a == 1 & d$b == 1 | runif(400) < .1))
  fit <- rpart::rpart(y ~ a + b, data = d, method = "class", control = rpart::rpart.control(cp = 0.001, minbucket = 10))
  ts <- TargetWise:::tree_structure(fit)
  expect_equal(nrow(ts), nrow(fit$frame))
  expect_true(all(ts$answer[-1] %in% c("yes", "no")))
  expect_equal(sum(ts$n[ts$leaf]), 400)
  svg <- TargetWise:::tree_svg(ts)
  expect_equal(lengths(regmatches(svg, gregexpr("<rect", svg))), nrow(ts))
  expect_equal(TargetWise:::tree_svg(NULL), "")
})

test_that("forest_svg draws one row per finite odds ratio", {
  w <- data.frame(criterion = c("a", "b", "c"), odds_ratio = c(2, 0.5, NA), or_low = c(1.2, 0.3, NA),
                  or_high = c(3.1, 0.9, NA), p_value = c(0.01, 0.2, NA))
  svg <- TargetWise:::forest_svg(w)
  expect_equal(lengths(regmatches(svg, gregexpr("<rect", svg))), 2)
  expect_equal(TargetWise:::forest_svg(w[3, ]), "")
})

test_that("a wide tree is drawn left to right and still has every node", {
  skip_if_not_installed("rpart")
  set.seed(2)
  d <- as.data.frame(matrix(rbinom(4000 * 8, 1, .5), ncol = 8))
  d$y <- factor(rbinom(4000, 1, plogis(rowSums(d[1:6] * c(1, -1, .8, -.8, .6, -.6)))))
  fit <- rpart::rpart(y ~ ., data = d, method = "class", control = rpart::rpart.control(cp = 0, maxdepth = 4, minbucket = 20))
  ts <- TargetWise:::tree_structure(fit)
  skip_if(sum(ts$leaf) <= 8)
  svg <- TargetWise:::tree_svg(ts)
  vb <- as.numeric(strsplit(gsub("viewBox=|\"", "", regmatches(svg, regexpr("viewBox=\"[^\"]+\"", svg))), " ")[[1]])
  expect_lt(vb[3], sum(ts$leaf) * 186 / 2)        # far narrower than the top-down layout
  expect_equal(lengths(regmatches(svg, gregexpr("<rect", svg))), nrow(ts))
})

test_that("network, importance and dendrogram diagrams come from the fitted models", {
  set.seed(3)
  d <- as.data.frame(matrix(rbinom(600 * 4, 1, .4), ncol = 4)); names(d) <- paste0("c", 1:4)
  d$.y <- factor(rbinom(600, 1, plogis(d$c1 * 2 - d$c2)))
  if (requireNamespace("nnet", quietly = TRUE)) {
    nn <- nnet::nnet(.y ~ ., data = d, size = 3, trace = FALSE)
    dg <- TargetWise:::model_diagram("nnet", nn)
    expect_equal(dg$kind, "network")
    expect_equal(nrow(dg$data$edges), 4 * 3 + 3)   # inputs x hidden + hidden x output, no biases
    expect_match(TargetWise:::diagram_svg(dg), "<circle")
  }
  im <- TargetWise:::importance_table(c(a = 2, b = 8, c = 0))
  expect_equal(im$criterion, c("b", "a")); expect_equal(im$importance, c(100, 25))
  hc <- stats::hclust(stats::dist(as.matrix(d[1:4])), method = "ward.D2")
  dd <- TargetWise:::dendro_structure(hc, 3, leaves = 12)
  expect_equal(sum(dd$leaves$size), 600)
  expect_equal(nrow(dd$joins), nrow(dd$leaves) - 1)
  expect_setequal(unique(dd$leaves$profile), 1:3)
  expect_match(TargetWise:::dendrogram_svg(dd), "cut: 3 profiles")
  expect_null(TargetWise:::model_diagram("svm", NULL))
})

test_that("pick_layout takes the shortest readable layout", {
  pl <- TargetWise:::pick_layout
  expect_equal(pl(list(c(800, 700), c(1400, 380))), 2L)   # two columns: shorter, still readable
  expect_equal(pl(list(c(800, 300), c(1400, 200))), 2L)
  expect_equal(pl(list(c(3000, 300), c(1100, 1200))), 2L) # the wide one would be unreadable
  expect_equal(pl(list(c(5000, 100), c(4000, 100))), 2L)  # none readable: the least shrunk
  expect_equal(TargetWise:::diagram_columns(5, 700, 26, 60), 1L)
})
