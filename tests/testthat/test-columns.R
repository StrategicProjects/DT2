# Tests for column-name resolution (the options$columns "footgun") and the
# automatic injection of options$columns by dt2().

test_that(".dt2_name_to_idx resolves names against options$columns", {
  expect_equal(.dt2_name_to_idx(c("b", "c"), list(columns = c("a", "b", "c"))),
               c(2L, 3L))
})

test_that(".dt2_name_to_idx passes 1-based numeric indices through", {
  expect_equal(.dt2_name_to_idx(c(2, 3), list()), c(2L, 3L))
})

test_that(".dt2_name_to_idx warns (not silent NA) when options$columns is unset", {
  expect_warning(idx <- .dt2_name_to_idx("x", list()), "options\\$columns")
  expect_true(all(is.na(idx)))
})

test_that(".dt2_name_to_idx warns on unknown column names", {
  expect_warning(idx <- .dt2_name_to_idx("zzz", list(columns = c("a", "b"))),
                 "Unknown column")
  expect_true(is.na(idx))
})

test_that("name-based helpers warn instead of failing silently", {
  expect_warning(dt2_cols_hide(list(), cols = "Species"),  "options\\$columns")
  expect_warning(dt2_cols_align(list(), "Species"),        "options\\$columns")
})

test_that("name-based helpers resolve correctly when columns are set", {
  o <- dt2_cols_hide(list(columns = c("a", "b", "c")), cols = c("b", "c"))
  expect_equal(vapply(o$columnDefs, function(d) d$targets, integer(1)), c(1L, 2L))
})

test_that("dt2() injects options$columns from the data when absent", {
  w <- dt2(head(iris, 2))
  expect_equal(w$x$options$columns, names(iris))
})

test_that("dt2() does not override user-provided options$columns", {
  cols <- c("A", "B", "C", "D", "E")
  w <- dt2(head(iris, 2), options = list(columns = cols))
  expect_equal(w$x$options$columns, cols)
})
