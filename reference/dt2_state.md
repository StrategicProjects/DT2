# Access the current state snapshot of a DT2 table

Returns a list with `reason`, `order`, `search`, `page`, `selected`,
`state` reflecting the current client-side table state.

## Usage

``` r
dt2_state(input, id)
```

## Arguments

- input:

  Shiny input object.

- id:

  Widget ID.

## Value

A list with the current table state.
