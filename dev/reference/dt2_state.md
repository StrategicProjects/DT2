# Access the current state snapshot of a DT2 table

Returns a list with `reason`, `order`, `search`, `page`, `selected`,
`rows_all`, `rows_current`, `rows_selected` and `state` reflecting the
current client-side table state.

## Usage

``` r
dt2_state(input, id)
```

## Arguments

- input:

  Shiny input object.

- id:

  Widget ID.

## Value

A list with the current table state.

## Details

The widget pushes `input$<id>_state` on every `init`, `draw`, `order`,
`search`, `page`, `select` and `deselect` event. Besides that snapshot,
it also sets three standalone inputs with the same names as the `DT`
package, all **1-based** row indices into the original data:

- `input$<id>_rows_all` – rows that survive the current filters (global
  search and per-column searches, e.g. from the ColumnControl
  extension), in display order.

- `input$<id>_rows_current` – the rows shown on the current page.

- `input$<id>_rows_selected` – the selected rows (Select extension).

The same vectors are available inside the snapshot as `rows_all`,
`rows_current` and `rows_selected`. The legacy `selected` element is
kept unchanged (0-based, as DataTables reports it).

With server-side processing the client only holds the current page, so
`rows_all` / `rows_current` are taken from the server response: the
default
[`dt2_ssp_handler()`](https://strategicprojects.github.io/DT2/dev/reference/dt2_ssp_handler.md)
ships them unless `rows_all = FALSE` (see
[`dt2_bind_server()`](https://strategicprojects.github.io/DT2/dev/reference/dt2_bind_server.md));
a custom handler must return `dt2_rows_all` / `dt2_rows_current` itself,
otherwise those inputs are `NULL`. In server mode `rows_selected` is
mapped through `rows_current` (so it is also `NULL` without it), and
only rows of the current page can be selected, because DataTables
discards server-side selections on every redraw. The `order`, `search`
and `page` snapshots fire before the server replies, so they carry
`NULL` row vectors; the `draw` snapshot that follows has the fresh
values (the standalone `input$<id>_rows_*` inputs only change on that
draw).
