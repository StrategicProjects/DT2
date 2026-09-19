# Format a date/time using DataTables' datetime renderer, with locale

Format a date/time using DataTables' datetime renderer, with locale

## Usage

``` r
dt2_format_time_format(
  options = list(),
  col_specs,
  from = NULL,
  to = "L",
  locale = "pt-br"
)
```

## Arguments

- options:

  Options list (returned modified).

- col_specs:

  Column names or indices to format.

- from:

  Input format (e.g. `'YYYY-MM-DDTHH:mm:ssZ'` or `NULL` for ISO).

- to:

  Output format (e.g. `'L LTS'`). See moment.js docs.

- locale:

  Locale string, e.g. `'pt-br'`.

## Value

Modified `options`.
