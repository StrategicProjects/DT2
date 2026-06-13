# Changelog

## DT2 0.1.2

### Bug fixes

- [`dt2_cols_escape()`](https://strategicprojects.github.io/DT2/reference/dt2_cols_escape.md)
  now actually escapes HTML when `escape = TRUE` (the default).
  Previously both `escape = TRUE` and `escape = FALSE` produced the same
  identity renderer, so cell content was always inserted as raw HTML.

- Server-side processing: the default request parser used by
  [`dt2_ssp_handler()`](https://strategicprojects.github.io/DT2/reference/dt2_ssp_handler.md)
  /
  [`dt2_bind_server()`](https://strategicprojects.github.io/DT2/reference/dt2_bind_server.md)
  now URL-decodes query-string *keys*, so global search and column
  ordering are applied. Previously only pagination worked, because
  encoded keys such as `search%5Bvalue%5D` and
  `order%5B0%5D%5Bcolumn%5D` were never matched.

### Improvements

- [`dt2()`](https://strategicprojects.github.io/DT2/reference/dt2.md)
  now fills `options$columns` from the data when it is not supplied,
  matching the column list the JavaScript side derives.

- Name-based column helpers (`dt2_cols_*()`, `dt2_format_*()`,
  [`dt2_order()`](https://strategicprojects.github.io/DT2/reference/dt2_order.md),
  …) now emit an informative warning when a column name cannot be
  resolved (for example when `options$columns` was not set), instead of
  silently producing an invalid target.

- The number and date/time format helpers build their JavaScript using
  properly quoted and escaped string literals, fixing broken output when
  a prefix, suffix, locale or format string contained a quote.

- [`print()`](https://rdrr.io/r/base/print.html) for `dt2_theme` objects
  now also shows the `class` field.

### Documentation and infrastructure

- Added a test suite (testthat) covering the fixes above.
- Added a GitHub Actions R-CMD-check workflow.
- Reorganised the pkgdown reference index into thematic sections, added
  runnable examples to
  [`dt2_order()`](https://strategicprojects.github.io/DT2/reference/dt2_order.md),
  [`dt2_search_global()`](https://strategicprojects.github.io/DT2/reference/dt2_search_global.md),
  [`dt2_use_buttons()`](https://strategicprojects.github.io/DT2/reference/dt2_use_buttons.md)
  and
  [`dt2_language()`](https://strategicprojects.github.io/DT2/reference/dt2_language.md),
  cross-linked
  [`dt2_buttons()`](https://strategicprojects.github.io/DT2/reference/dt2_buttons.md)/[`dt2_use_buttons()`](https://strategicprojects.github.io/DT2/reference/dt2_use_buttons.md),
  and documented the `options$columns` pattern in the vignettes.
- New package logo.

## DT2 0.1.1

CRAN release: 2026-05-04

- First CRAN release.

## DT2 0.1.0

- Initial development version.
