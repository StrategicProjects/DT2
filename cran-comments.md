## Update

This is a minor update (0.1.3) of a package already on CRAN (0.1.2). It adds
one feature requested by users and fixes two bugs in the 'shiny' server-side
processing path; see NEWS.md for details.

* New 'shiny' inputs `input$<id>_rows_all`, `input$<id>_rows_current` and
  `input$<id>_rows_selected` report which rows are visible after filtering
  (same names and semantics as the 'DT' package). `dt2_ssp_handler()` and
  `dt2_bind_server()` gain a `rows_all` argument (default `TRUE`); no existing
  argument changed.
* `options = list(server_side = TRUE)` now actually enables server-side
  processing (the flag was previously ignored).
* Column ordering is now applied in server-side mode (the request encoder in
  the bundled JavaScript dropped the nested `order` parameters).

There are no reverse dependencies on CRAN.

## Test environments

* local macOS, R 4.6.0
* GitHub Actions: ubuntu-latest (r-devel, r-release, r-oldrel-1),
  macOS-latest (r-release), windows-latest (r-release)
* win-builder (r-devel, r-release)

## R CMD check results

0 errors | 0 warnings | 0 notes

The package bundles the 'DataTables' JavaScript library and its extensions,
so the installed size may be reported as a NOTE on some CRAN check machines
(unchanged from 0.1.2).
