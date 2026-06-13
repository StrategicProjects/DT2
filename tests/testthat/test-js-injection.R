# Tests for safe JS string interpolation in the format helpers.
# Previously strings were injected with sprintf("'%s'", x), which produced
# invalid JS when the value itself contained a quote.

test_that(".dt2_js_str produces valid, escaped JS string literals", {
  expect_equal(.dt2_js_str("R$"),        '"R$"')
  expect_equal(.dt2_js_str("a\"b"),      '"a\\"b"')
  expect_equal(.dt2_js_str(NULL),        "null")
  expect_equal(.dt2_js_str(NULL, "undefined"), "undefined")
})

test_that("dt2_format_number safely quotes a prefix containing a quote", {
  o <- dt2_format_number(list(columns = "x"), 1, prefix = "O'Brien $")
  r <- as.character(o$columnDefs[[1]]$render)
  # valid double-quoted JS literal ...
  expect_true(grepl('"O\'Brien $"', r, fixed = TRUE))
  # ... not the broken single-quoted form
  expect_false(grepl("'O'Brien $'", r, fixed = TRUE))
})

test_that("dt2_format_number renders NULL separators as null", {
  o <- dt2_format_number(list(columns = "x"), 1,
                         thousands = NULL, decimal = NULL, digits = 2)
  r <- as.character(o$columnDefs[[1]]$render)
  expect_true(grepl("render.number(null,null,2", r, fixed = TRUE))
})

test_that("dt2_format_datetime renders NULL args as undefined", {
  o <- dt2_format_datetime(list(columns = "x"), 1, from = NULL, to = "DD/MM/YYYY")
  r <- as.character(o$columnDefs[[1]]$render)
  expect_true(grepl("undefined", r, fixed = TRUE))
  expect_true(grepl('"DD/MM/YYYY"', r, fixed = TRUE))
})
