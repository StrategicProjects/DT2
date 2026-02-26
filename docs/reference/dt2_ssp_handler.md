# Default server-side handler (filter/order/page)

Default server-side handler (filter/order/page)

## Usage

``` r
dt2_ssp_handler(names)
```

## Arguments

- names:

  character() column names in display order.

## Value

function(data, req) -\> list(draw, recordsTotal, recordsFiltered, data)
