# Bind a DataTables v2 server-side endpoint to a widget id

Bind a DataTables v2 server-side endpoint to a widget id

## Usage

``` r
dt2_bind_server(
  id,
  data,
  session = shiny::getDefaultReactiveDomain(),
  handler = NULL
)
```

## Arguments

- id:

  Output id of the widget (e.g., "tbl").

- data:

  A data.frame with the source data.

- session:

  Shiny session (default: current).

- handler:

  Optional custom handler function(data, req) -\> list(...).
