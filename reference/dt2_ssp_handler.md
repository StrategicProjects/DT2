# Default server-side handler (filter/order/page)

Default server-side handler (filter/order/page)

## Usage

``` r
dt2_ssp_handler(names, rows_all = TRUE)
```

## Arguments

- names:

  character() column names in display order.

- rows_all:

  Logical. If `TRUE` (default), the response also carries the 1-based
  indices (into the source data) of all rows that survive the current
  filter (`dt2_rows_all`) and of the rows on the current page
  (`dt2_rows_current`). dt2.js forwards them to `input$<id>_rows_all`
  and `input$<id>_rows_current`, mirroring the client-side behaviour.
  Set to `FALSE` for very large tables, where shipping the full index
  vector on every draw is too costly; the two inputs are then `NULL`.

## Value

function(data, req) -\> list(draw, recordsTotal, recordsFiltered, data,
and optionally dt2_rows_all, dt2_rows_current)
