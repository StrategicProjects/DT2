# Shiny render function for DT2

Render a DT2 table in a Shiny server function.

## Usage

``` r
render_dt2(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- expr:

  Expression returning a
  [`dt2()`](https://strategicprojects.github.io/DT2/reference/dt2.md)
  widget.

- env, quoted:

  Standard `shinyRenderWidget` arguments.

## Value

A Shiny render function (closure produced by
[`htmlwidgets::shinyRenderWidget()`](https://rdrr.io/pkg/htmlwidgets/man/htmlwidgets-shiny.html))
that emits a DT2 widget.
