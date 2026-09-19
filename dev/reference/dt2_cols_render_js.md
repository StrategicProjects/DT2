# Attach a raw JS render function to columns

Provide a custom JS renderer for one or more columns. Use this when you
need fine control over `columns.render`, including returning different
outputs based on `type` (display/sort/filter/type).

## Usage

``` r
dt2_cols_render_js(options = list(), col_specs, js_render)
```

## Arguments

- options:

  List returned, with `columnDefs` appended.

- col_specs:

  Column names or indices.

- js_render:

  A [`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html)
  function of signature `function(data, type, row, meta) { ... }`.

## Value

Modified `options`.

## See also

<https://datatables.net/reference/option/columns.render>
