# Global search (proxy)

Global search (proxy)

## Usage

``` r
dt2_proxy_search(
  proxy,
  value,
  regex = FALSE,
  smart = TRUE,
  caseInsensitive = TRUE
)
```

## Arguments

- proxy:

  A
  [`dt2_proxy()`](https://strategicprojects.github.io/DT2/reference/dt2_proxy.md)
  object.

- value:

  Search string.

- regex:

  Logical; treat `value` as a regular expression? Default: `FALSE`.

- smart:

  Logical; use DataTables smart search? Default: `TRUE`.

- caseInsensitive:

  Logical; case-insensitive search? Default: `TRUE`.

## Value

The proxy, invisibly.
