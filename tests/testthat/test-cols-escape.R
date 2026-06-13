# Regression tests for dt2_cols_escape().
# Bug: both branches of `if (escape)` returned the identical identity function
# `function(d,t){return d;}`, so `escape` was a no-op and the default
# (escape = TRUE) rendered raw HTML instead of escaping it.

test_that("dt2_cols_escape() escapes HTML special chars when escape = TRUE", {
  o <- dt2_cols_escape(list(columns = "x"), 1, escape = TRUE)
  r <- as.character(o$columnDefs[[1]]$render)
  expect_true(grepl("&lt;",   r, fixed = TRUE))
  expect_true(grepl("&gt;",   r, fixed = TRUE))
  expect_true(grepl("&amp;",  r, fixed = TRUE))
  expect_true(grepl("&quot;", r, fixed = TRUE))
})

test_that("dt2_cols_escape() renders raw HTML when escape = FALSE", {
  o <- dt2_cols_escape(list(columns = "x"), 1, escape = FALSE)
  r <- as.character(o$columnDefs[[1]]$render)
  expect_false(grepl("&lt;", r, fixed = TRUE))
})

test_that("dt2_cols_escape() TRUE and FALSE yield different renderers", {
  t_render <- as.character(
    dt2_cols_escape(list(columns = "x"), 1, escape = TRUE)$columnDefs[[1]]$render
  )
  f_render <- as.character(
    dt2_cols_escape(list(columns = "x"), 1, escape = FALSE)$columnDefs[[1]]$render
  )
  expect_false(identical(t_render, f_render))
})
