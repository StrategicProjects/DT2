# Register a named JS renderer

Register a named JS renderer

## Usage

``` r
dt2_register_renderer(name, js)
```

## Arguments

- name:

  Unique name (character scalar).

- js:

  A [`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html)
  function or a JSON helper expression.

## Value

Invisibly, the name.
