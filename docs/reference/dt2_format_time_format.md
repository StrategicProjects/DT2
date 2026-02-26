# Format a date/time using DataTables' datetime renderer, with locale

Format a date/time using DataTables' datetime renderer, with locale

## Usage

``` r
dt2_format_time_format(
  options = list(),
  col_specs,
  from = NULL,
  to = "L",
  locale = "pt-br"
)
```

## Arguments

- from:

  input format (e.g. 'YYYY-MM-DDTHH:mm:ssZ' or null for ISO)

- to:

  output format (e.g. 'L LTS') - ver moment.js

- locale:

  e.g. 'pt-br'
