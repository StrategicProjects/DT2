# Allow raw HTML rendering via `columns.render`

Mark columns to render raw HTML using a JS render function.

## Usage

``` r
dt2_cols_html(options = list(), cols, js_render)
```

## Arguments

- options:

  Options list.

- cols:

  Names or 1-based indices.

- js_render:

  JS function (via
  [htmlwidgets::JS](https://rdrr.io/pkg/htmlwidgets/man/JS.html)) with
  signature `(data, type, row, meta)` returning a string of HTML when
  `type == "display"`.

## Value

Updated `options`.
