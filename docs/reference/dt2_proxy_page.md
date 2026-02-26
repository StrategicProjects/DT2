# Page navigation (proxy)

Page navigation (proxy)

## Usage

``` r
dt2_proxy_page(
  proxy,
  page = c("first", "previous", "next", "last", "number"),
  number = NULL
)
```

## Arguments

- proxy:

  A
  [`dt2_proxy()`](https://strategicprojects.github.io/DT2/reference/dt2_proxy.md)
  object.

- page:

  Navigation action: `"first"`, `"previous"`, `"next"`, `"last"`, or
  `"number"` (go to a specific page).

- number:

  Page number (1-based). Only used when `page = "number"`.

## Value

The proxy, invisibly.
