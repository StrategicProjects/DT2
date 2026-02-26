# Orthogonal render (display/sort/filter/type) per column

Supply different renderers for each orthogonal data request. Pass an
object with keys `display`, `sort`, `filter`, `type` (all optional).
Each value must be a JS function.

## Usage

``` r
dt2_cols_render_orthogonal(
  options = list(),
  col_specs,
  display = NULL,
  sort = NULL,
  filter = NULL,
  type = NULL
)
```

## Arguments

- options:

  Options list to modify.

- col_specs:

  Column names or indices.

- display:

  Optional JS renderer for UI display.

- sort:

  Optional JS renderer used for ordering.

- filter:

  Optional JS renderer used for searching.

- type:

  Optional JS renderer used for type detection.

## Value

Modified `options`.

## Examples

``` r
if (FALSE) { # \dontrun{
opts <- list(columns = names(iris))
opts <- dt2_cols_render_orthogonal(
  opts, "Sepal.Length",
  display = DT2::JS("function(d,t,row,meta){ return d + ' cm'; }"),
  sort    = DT2::JS("function(d,t,row,meta){ return parseFloat(d); }")
)
} # }
```
