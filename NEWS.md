# DT2 0.1.2

## Bug fixes

* `dt2_cols_escape()` now actually escapes HTML when `escape = TRUE` (the
  default). Previously both `escape = TRUE` and `escape = FALSE` produced the
  same identity renderer, so cell content was always inserted as raw HTML.

* Server-side processing: the default request parser used by
  `dt2_ssp_handler()` / `dt2_bind_server()` now URL-decodes query-string
  *keys*, so global search and column ordering are applied. Previously only
  pagination worked, because encoded keys such as `search%5Bvalue%5D` and
  `order%5B0%5D%5Bcolumn%5D` were never matched.

## Improvements

* `dt2()` now fills `options$columns` from the data when it is not supplied,
  matching the column list the JavaScript side derives.

* Name-based column helpers (`dt2_cols_*()`, `dt2_format_*()`, `dt2_order()`,
  ...) now emit an informative warning when a column name cannot be resolved
  (for example when `options$columns` was not set), instead of silently
  producing an invalid target.

* The number and date/time format helpers build their JavaScript using
  properly quoted and escaped string literals, fixing broken output when a
  prefix, suffix, locale or format string contained a quote.

* `print()` for `dt2_theme` objects now also shows the `class` field.

## Documentation and infrastructure

* Added a test suite (testthat) covering the fixes above.
* Added a GitHub Actions R-CMD-check workflow.
* Reorganised the pkgdown reference index into thematic sections, added
  runnable examples to `dt2_order()`, `dt2_search_global()`,
  `dt2_use_buttons()` and `dt2_language()`, cross-linked
  `dt2_buttons()`/`dt2_use_buttons()`, and documented the `options$columns`
  pattern in the vignettes.
* New package logo.

# DT2 0.1.1

* First CRAN release.

# DT2 0.1.0

* Initial development version.
