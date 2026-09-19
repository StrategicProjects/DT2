# Bind a DataTables v2 server-side endpoint to a widget id

Bind a DataTables v2 server-side endpoint to a widget id

## Usage

``` r
dt2_bind_server(
  id,
  data,
  session = shiny::getDefaultReactiveDomain(),
  handler = NULL,
  rows_all = TRUE
)
```

## Arguments

- id:

  Output id of the widget (e.g., "tbl").

- data:

  A data.frame with the source data.

- session:

  Shiny session (default: current).

- handler:

  Optional custom handler function(data, req) -\> list(...). A custom
  handler may include `dt2_rows_all` / `dt2_rows_current` (1-based row
  indices) in its result to feed `input$<id>_rows_all` and
  `input$<id>_rows_current`; see
  [`dt2_ssp_handler()`](https://strategicprojects.github.io/DT2/dev/reference/dt2_ssp_handler.md).

- rows_all:

  Passed to
  [`dt2_ssp_handler()`](https://strategicprojects.github.io/DT2/dev/reference/dt2_ssp_handler.md)
  when `handler` is `NULL`: whether the default handler ships the
  filtered row indices to the client.

## Value

No return value, called for side effects. Registers a Shiny observer on
`session` that responds to client-side server-processing requests for
the given widget `id`.
