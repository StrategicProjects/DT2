# Configure DataTables Buttons and (optionally) move them to a custom container

Configure DataTables Buttons and (optionally) move them to a custom
container

## Usage

``` r
dt2_buttons(
  options = list(),
  buttons = c("copyHtml5", "csvHtml5", "excelHtml5", "pdfHtml5", "print"),
  target = NULL
)
```

## Arguments

- options:

  A DT2 `options` list you are building.

- buttons:

  Character vector with button names (e.g. `"copyHtml5"`, `"csvHtml5"`,
  `"excelHtml5"`, `"pdfHtml5"`, `"print"`). You can also pass a list
  with full button objects.

- target:

  Optional CSS selector (e.g. `"#btn-slot"` or `".my-toolbar"`) to
  receive the buttons container. If provided, DT2 will move the rendered
  buttons to that container after init.

## Value

The modified `options` list.

## Details

Requires the **Buttons** extension. For CSV/Excel/PDF you also need
**JSZip** and **pdfMake** (incl. `vfs_fonts`).
