# Extensions Guide

## How Extensions Work

DT2 loads extensions **on demand**. Instead of shipping all 15+
extensions to every page, only the CSS/JS for extensions you actually
use are included.

There are two ways to specify extensions:

1.  **Explicit** — pass `extensions = c("Buttons", "Select")` to
    [`dt2()`](https://monitoramento.sepe.pe.gov.br/DT2/reference/dt2.md)
2.  **Auto-detection** — DT2 scans your `options` list and infers which
    extensions are needed (this is the default when `extensions = NULL`)

### Listing Available Extensions

``` r

dt2_extensions()
#>                        name version           dir
#> Buttons             Buttons   3.2.5       buttons
#> ColReorder       ColReorder   2.1.1    colreorder
#> ColumnControl ColumnControl   1.1.0 columncontrol
#> DateTime           DateTime   1.6.0      datetime
#> FixedColumns   FixedColumns   5.0.5  fixedcolumns
#> FixedHeader     FixedHeader   4.0.3   fixedheader
#> KeyTable           KeyTable  2.12.1      keytable
#> Responsive       Responsive   3.0.6    responsive
#> RowGroup           RowGroup   1.6.0      rowgroup
#> RowReorder       RowReorder   1.5.0    rowreorder
#> Scroller           Scroller   2.4.3      scroller
#> SearchBuilder SearchBuilder   1.8.4 searchbuilder
#> SearchPanes     SearchPanes   2.3.5   searchpanes
#> Select               Select   3.1.0        select
#> StateRestore   StateRestore   1.4.2  staterestore
```

## Buttons (Export / Copy / Print)

The Buttons extension adds export and utility buttons.

``` r

dt2(mtcars[1:15, ], extensions = "Buttons", options = list(
  pageLength = 8,
  layout = list(
    topEnd = list(
      buttons = list("copy", "csv", "excel", "pdf", "print")
    )
  )
))
```

### Grouped Buttons with Labels

``` r

dt2(iris[1:20, ], options = list(
  pageLength = 10,
  layout = list(
    topStart = "pageLength",
    topEnd = list(
      buttons = list(
        list(extend = "collection", text = "Export",
             buttons = list(
               list(extend = "copyHtml5", text = "Copy"),
               list(extend = "csvHtml5"),
               list(extend = "excelHtml5", title = "My Data"),
               list(extend = "pdfHtml5",   title = "My Data")
             )),
        list(extend = "colvis", text = "Columns")
      ),
      search = list(placeholder = "Filter...")
    ),
    bottomEnd = "paging"
  )
))
```

Note: DT2 auto-detected that `layout` contains `buttons`, so it loaded
the Buttons extension automatically (no need to set `extensions`
explicitly).

## Select (Row Selection)

Enable row selection with the Select extension:

``` r

dt2(iris[1:20, ], options = list(
  select = list(style = "os", items = "row"),
  pageLength = 10
))
```

In Shiny, selected rows are available via `input$<id>_state$selected`.

## Responsive

DT2 enables the Responsive extension by default. Tables fill 100% width
and columns that don’t fit are collapsed into expandable child rows.

To disable for a specific table:

``` r

dt2(iris, responsive = FALSE, options = list(pageLength = 5))
```

To customise Responsive behaviour (e.g., disable child rows):

``` r

dt2(iris, options = list(
  responsive = list(details = FALSE)  # hide overflow silently
))
```

## ColumnControl

ColumnControl adds per-column controls (order indicators, search
dropdowns, column visibility) directly in the table header:

``` r

dt2(iris, options = list(
  pageLength = 8,
  columnControl = list("order", "searchDropdown",
    list(
      list(extend = "orderAsc",  text = "Sort Ascending"),
      list(extend = "orderDesc", text = "Sort Descending"),
      "spacer",
      list(extend = "colVisDropdown", text = "Toggle Columns")
    )
  ),
  ordering = list(indicators = FALSE, handler = FALSE)
))
```

## FixedHeader

Keep the header visible while scrolling:

``` r

dt2(iris, options = list(fixedHeader = TRUE, pageLength = 50))
```

## Combining Extensions

Extensions compose naturally. Here’s Buttons + Select + ColumnControl:

``` r

dt2(iris, options = list(
  pageLength = 8,
  select = list(style = "multi", items = "row"),
  layout = list(
    topEnd = list(
      buttons = list(
        list(extend = "selected",  text = "Selected Only"),
        list(extend = "selectAll", text = "Select All"),
        list(extend = "selectNone", text = "Deselect"),
        "spacer",
        list(extend = "csvHtml5", exportOptions = list(modifier = list(selected = TRUE)))
      )
    )
  ),
  columnControl = list("order", "searchDropdown"),
  ordering = list(indicators = FALSE, handler = FALSE)
))
```

## Adding New Plugins

To add a DataTables plugin not yet in the registry:

1.  Add version variable and download commands in
    `tools/get-dt2-libs.sh`
2.  Register it in `R/dt2_extensions.R`
    ([`.dt2_extension_registry()`](https://monitoramento.sepe.pe.gov.br/DT2/reference/dt2-extensions.md))
3.  Add auto-detection rules in
    [`.dt2_detect_extensions()`](https://monitoramento.sepe.pe.gov.br/DT2/reference/dot-dt2_detect_extensions.md)
4.  Add npm mapping in `R/dt2_check_updates.R`
    ([`.dt2_npm_map()`](https://monitoramento.sepe.pe.gov.br/DT2/reference/dot-dt2_npm_map.md))
5.  Run `bash tools/get-dt2-libs.sh` to download the files
6.  Test with `dt2(data, extensions = "YourPlugin")`

The declarative registry in `dt2_extensions.R` is the single source of
truth for extension metadata (version, JS files, CSS files,
dependencies).

## Updating Library Versions

Check for newer versions of all bundled JS/CSS libraries:

``` r

dt2_check_updates()
```

    Library            Installed   Latest      Compat.     Status
    -----------------------------------------------------------------
    DataTables         2.3.4       2.3.7       2.3.7       ⚠️  UPDATE
    jQuery             3.7.0       4.0.0       3.7.1       🔒 PINNED [pin: 3.x]
    Buttons            3.2.5       3.2.6       3.2.6       ⚠️  UPDATE
    ...

If you are developing DT2 (working from the source tree), apply
compatible updates automatically:

``` r

dt2_update_libs()                    # patch files + download new JS/CSS
dt2_update_libs(dry_run = TRUE)      # preview without changing anything
dt2_update_libs(download = FALSE)    # patch R files only (manual download)
```

Version constraints prevent incompatible upgrades:

- **jQuery** pinned to 3.x (DataTables 2 requires jQuery 3)
- **pdfmake** pinned to 0.2.x (0.3.x has breaking changes)
- **Bootstrap** pinned to 5.x

Libraries marked as `PINNED` are up to date within their allowed range.
Edit
[`.dt2_version_constraints()`](https://monitoramento.sepe.pe.gov.br/DT2/reference/dot-dt2_version_constraints.md)
to change the allowed ranges.
