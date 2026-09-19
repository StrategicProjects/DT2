# Internal: build DataTables JSON payload

`rows_all` / `rows_current` (1-based indices into the source data) are
optional; when supplied they are shipped as `dt2_rows_all` /
`dt2_rows_current` and dt2.js forwards them to `input$<id>_rows_all` /
`input$<id>_rows_current`.

## Usage

``` r
.dt2_payload(
  draw,
  total,
  filtered,
  data_rows,
  rows_all = NULL,
  rows_current = NULL
)
```
