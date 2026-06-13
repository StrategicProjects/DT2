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

Prefer
[`dt2_use_buttons()`](https://strategicprojects.github.io/DT2/reference/dt2_use_buttons.md)
for the common case: it takes simple button ids, styles them with a CSS
class, and places them in the layout. Use `dt2_buttons()` when you need
full button objects or want to move the rendered buttons into a custom
container via `target`.

## See also

[`dt2_use_buttons()`](https://strategicprojects.github.io/DT2/reference/dt2_use_buttons.md)
