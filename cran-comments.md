## Resubmission

This is a resubmission addressing the comments from Benjamin Altmann
(2026-04-08):

* Title and Description now use single quotes only around package /
  software / API names ('DataTables', 'Bootstrap 5', 'Shiny',
  'JavaScript'). The reference to R itself is no longer quoted.

* Added \value tags to all exported functions that were missing them:
  dt2_bind_server, dt2_draw, dt2_format_time_relative, dt2_output,
  dt2_proxy_order, dt2_replace_data, dt2_select_rows,
  observe_dt2_events, render_dt2.

* Replaced \dontrun{} examples:
  - dt2_format_number, dt2_format_datetime, dt2_cols_render_orthogonal:
    examples unwrapped (they only build option lists and run in < 1s).
  - dt2_check_updates: changed to \donttest{}, since it reaches the
    npm registry over the network.
  - dt2_update_libs: kept as \dontrun{} (with an explanatory comment),
    because this is a developer-only tool that requires the DT2 package
    source tree (DESCRIPTION, tools/get-dt2-libs.sh, R/dt2_extensions.R)
    and therefore truly cannot be executed by the user from an installed
    package or from a CRAN check environment.

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Andre Leite <leite@castlab.org>'
  New submission

  This NOTE is expected for a first-time submission.
