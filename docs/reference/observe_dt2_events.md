# Observe DataTables events published by dt2.js

Listen for table events (init, draw, order, search, page, select,
deselect).

## Usage

``` r
observe_dt2_events(input, id, handler)
```

## Arguments

- input:

  Shiny input object.

- id:

  Widget ID.

- handler:

  Function with signature `(event, type, indexes, rowData)`.
