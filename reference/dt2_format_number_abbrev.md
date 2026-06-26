# Abbreviate large numbers with fixed decimals (k / M / B)

Adds a `columns.render` function that displays numbers as 1.2k, 3.4M,
etc. This renderer **lets you control** the number of decimal places via
`digits`. Use this when you want a fixed, compact style independent of
locale rules.

## Usage

``` r
dt2_format_number_abbrev(
  options = list(),
  col_specs,
  digits = 1,
  locale = NULL
)
```

## Arguments

- options:

  A DataTables options list to be modified.

- col_specs:

  Column names or 1-based indices to format.

- digits:

  Integer, decimal places for the abbreviated display (default 1).

- locale:

  Optional BCP-47 locale string (e.g. "pt-BR"). If provided, the
  non-abbreviated part uses `toLocaleString(locale)` for grouping.

## Value

The modified `options` list.

## Examples

``` r
opts <- list(columns = names(mtcars))
opts <- dt2_format_number_abbrev(opts, c("hp","qsec"), digits = 1, locale = "pt-BR")
```
