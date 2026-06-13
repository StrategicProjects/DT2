# print.dt2_theme() previously omitted the `class` field.

test_that("print.dt2_theme() shows the class field", {
  expect_output(print(dt2_theme("default")), "class")
})

test_that("dt2_theme() applies preset overrides", {
  th <- dt2_theme("minimal", striped = TRUE)
  expect_s3_class(th, "dt2_theme")
  expect_true(th$striped)
  expect_false(th$hover)  # from the 'minimal' preset
})
