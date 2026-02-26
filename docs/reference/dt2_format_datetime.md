# Format date/time columns (DataTables renderer: datetime)

Use DataTables' built-in `DataTable.render.datetime` to transform
date/time strings for display (and preserve sortability).

## Usage

``` r
dt2_format_datetime(
  options = list(),
  col_specs,
  from = NULL,
  to = "DD/MM/YYYY",
  locale = NULL,
  def = NULL
)
```

## Arguments

- options:

  List of options (returned with `columnDefs` updated).

- col_specs:

  Column names or 1-based indices.

- from:

  Input format (e.g., `"YYYY-MM-DD"` or ISO8601 by default).

- to:

  Output format (e.g., `"DD/MM/YYYY"`).

- locale:

  Optional locale (e.g., `"pt-BR"`).

- def:

  Optional default output if input is invalid.

## Value

Modified `options`.

## Examples

``` r
if (FALSE) { # \dontrun{
opts <- list(columns = c("when", "val"))
opts <- dt2_format_datetime(opts, "when", from = "YYYY-MM-DD", to = "DD/MM/YYYY", locale = "pt-BR")
} # }
```
