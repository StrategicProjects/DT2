# Escape/unescape columns content

Controls whether cell content is HTML-escaped before display.

## Usage

``` r
dt2_cols_escape(options = list(), cols, escape = TRUE)
```

## Arguments

- options:

  Options list.

- cols:

  Names or indices.

- escape:

  If `TRUE` (default), HTML special characters are escaped so the raw
  text is shown. If `FALSE`, the content is rendered as raw HTML (use
  with care; only for trusted content).

## Value

Updated `options`.
