# Regression tests for the server-side processing (SSP) request parser.
# Bug: dt2.js encodes query-string KEYS with encodeURIComponent
# (e.g. "search[value]" -> "search%5Bvalue%5D"), but the parser only
# URL-decoded the values, never the keys. As a result global search and
# ordering were silently never applied -- only pagination worked.

# Mirror how dt2.js encodes a key (encodeURIComponent on the key text).
enc <- function(s) utils::URLencode(s, reserved = TRUE)

ssp_qs <- function(...) paste(..., sep = "&")

test_that(".dt2_parse_ssp_request decodes encoded search/order keys", {
  qs <- ssp_qs(
    "draw=2", "start=0", "length=10",
    paste0(enc("search[value]"),     "=", enc("foo bar")),
    paste0(enc("search[regex]"),     "=false"),
    paste0(enc("order[0][column]"),  "=1"),
    paste0(enc("order[0][dir]"),     "=desc")
  )
  pars <- .dt2_parse_ssp_request(list(QUERY_STRING = qs), n_cols = 3)

  expect_equal(pars$draw, 2L)
  expect_equal(pars$search$value, "foo bar")  # was NULL before the fix
  expect_false(pars$search$regex)
  expect_length(pars$order, 1)
  expect_equal(pars$order[[1]]$column, 2L)     # 0-based 1 -> 1-based 2
  expect_equal(pars$order[[1]]$dir, "desc")
})

test_that("dt2_ssp_handler applies global search and ordering end-to-end", {
  df <- data.frame(
    id   = 1:5,
    name = c("alpha", "beta", "gamma", "Alpha", "BETA"),
    stringsAsFactors = FALSE
  )
  h <- dt2_ssp_handler(names(df))

  qs <- ssp_qs(
    "draw=1", "start=0", "length=10",
    paste0(enc("search[value]"),    "=", enc("alpha")),
    paste0(enc("order[0][column]"), "=0"),
    paste0(enc("order[0][dir]"),    "=desc")
  )
  out <- h(df, list(QUERY_STRING = qs))

  expect_equal(out$recordsTotal, 5L)
  # case-insensitive global search matches "alpha" and "Alpha"
  expect_equal(out$recordsFiltered, 2L)
  # ordered by id descending -> first row is id 4 ("Alpha"), not id 1
  expect_equal(out$data[[1]]$id, 4L)
})

test_that("dt2_ssp_handler paginates", {
  df <- data.frame(id = 1:100)
  h  <- dt2_ssp_handler(names(df))
  qs <- ssp_qs("draw=1", "start=20", "length=5")
  out <- h(df, list(QUERY_STRING = qs))

  expect_equal(out$recordsTotal, 100L)
  expect_equal(out$recordsFiltered, 100L)
  expect_equal(length(out$data), 5L)
  expect_equal(out$data[[1]]$id, 21L)
})
