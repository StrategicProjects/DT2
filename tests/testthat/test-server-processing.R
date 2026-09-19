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

test_that("dt2_ssp_handler ships 1-based filtered/current row indices (#20)", {
  df <- data.frame(
    id   = 1:6,
    name = c("alpha", "beta", "gamma", "Alpha", "BETA", "delta"),
    stringsAsFactors = FALSE
  )
  h <- dt2_ssp_handler(names(df))

  # filter "e" (matches beta, BETA, delta -> ids 2, 5, 6), order id desc
  qs <- ssp_qs(
    "draw=1", "start=0", "length=2",
    paste0(enc("search[value]"),    "=", enc("e")),
    paste0(enc("order[0][column]"), "=0"),
    paste0(enc("order[0][dir]"),    "=desc")
  )
  out <- h(df, list(QUERY_STRING = qs))

  expect_equal(out$recordsFiltered, 3L)
  # rows_all: original row numbers of the filtered set, in display order
  expect_equal(as.integer(out$dt2_rows_all), c(6L, 5L, 2L))
  # rows_current: the page slice of rows_all
  expect_equal(as.integer(out$dt2_rows_current), c(6L, 5L))
  # the data rows correspond to rows_current
  expect_equal(vapply(out$data, function(r) r$id, integer(1)), c(6L, 5L))
  # arrays survive auto-unbox (length-1 must still be an array)
  expect_s3_class(out$dt2_rows_all, "AsIs")

  # second page
  qs2 <- sub("start=0", "start=2", qs, fixed = TRUE)
  out2 <- h(df, list(QUERY_STRING = qs2))
  expect_equal(as.integer(out2$dt2_rows_current), 2L)
  expect_s3_class(out2$dt2_rows_current, "AsIs")

  # empty result
  qs3 <- ssp_qs("draw=1", "start=0", "length=10",
                paste0(enc("search[value]"), "=zzz"))
  out3 <- h(df, list(QUERY_STRING = qs3))
  expect_equal(out3$recordsFiltered, 0L)
  expect_length(out3$dt2_rows_all, 0)
  expect_length(out3$dt2_rows_current, 0)
})

test_that("dt2_ssp_handler(rows_all = FALSE) omits the index vectors", {
  df <- data.frame(id = 1:10)
  h  <- dt2_ssp_handler(names(df), rows_all = FALSE)
  out <- h(df, list(QUERY_STRING = ssp_qs("draw=1", "start=0", "length=5")))
  expect_null(out$dt2_rows_all)
  expect_null(out$dt2_rows_current)
  expect_equal(length(out$data), 5L)
})

test_that("dt2() lifts options$server_side to the payload and ships no rows (#22)", {
  df <- data.frame(id = 1:50, g = rep(c("a", "b"), 25))
  for (key in c("server_side", "serverSide")) {
    w <- dt2(df, options = stats::setNames(list(TRUE, 10), c(key, "pageLength")))
    expect_true(isTRUE(w$x$server_side))
    expect_equal(nrow(w$x$data), 0L)
    expect_equal(names(w$x$data), names(df))
    expect_null(w$x$options$server_side)
    expect_null(w$x$options$serverSide)
    expect_equal(unlist(w$x$options$columns), names(df))
  }
  # client-side default is untouched
  w <- dt2(df)
  expect_null(w$x$server_side)
  expect_equal(nrow(w$x$data), 50L)
})

test_that("parser handles the query string dt2.js really sends (#22)", {
  # Captured shape: nested arrays of objects flattened as key[i][sub]
  qs <- ssp_qs(
    "draw=3",
    paste0(enc("columns[0][data]"), "=id"),
    paste0(enc("columns[0][search][value]"), "="),
    paste0(enc("columns[1][data]"), "=name"),
    paste0(enc("order[0][column]"), "=1"),
    paste0(enc("order[0][dir]"), "=desc"),
    paste0(enc("order[0][name]"), "="),
    "start=0", "length=2",
    paste0(enc("search[value]"), "="),
    paste0(enc("search[regex]"), "=false")
  )
  df <- data.frame(id = 1:3, name = c("b", "c", "a"), stringsAsFactors = FALSE)
  out <- dt2_ssp_handler(names(df))(df, list(QUERY_STRING = qs))
  expect_equal(out$draw, 3L)
  expect_equal(vapply(out$data, function(r) r$name, character(1)), c("c", "b"))
  expect_equal(as.integer(out$dt2_rows_all), c(2L, 1L, 3L))
})
