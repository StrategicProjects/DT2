# Format numeric columns (DataTables renderer: number)

Add a number renderer to one or more columns using DataTables' built-in
`DataTable.render.number`.

## Usage

``` r
dt2_format_number(
  options = list(),
  col_specs,
  thousands = NULL,
  decimal = NULL,
  digits = 0,
  prefix = "",
  prefix_right = ""
)
```

## Arguments

- options:

  List of options (returned, with `columnDefs` updated).

- col_specs:

  Column names or 1-based indices to format.

- thousands:

  Thousands separator (character or `NULL` for auto).

- decimal:

  Decimal separator (character or `NULL` for auto).

- digits:

  Number of decimal places.

- prefix, prefix_right:

  String to prepend/append (e.g., currency symbol).

## Value

Modified `options`.

## Examples

``` r
if (FALSE) { # \dontrun{
opts <- list(columns = names(iris))
opts <- dt2_format_number(opts, "Sepal.Length", thousands = ".", decimal = ",",
                          digits = 2, prefix = "", prefix_right = "")
} # }
```
