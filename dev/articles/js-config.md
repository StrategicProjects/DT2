# Translating DataTables.net Config to R

## The 1:1 Mapping Principle

DT2’s `options` argument maps directly to the DataTables JavaScript
configuration object. An R named list becomes a JS object; R vectors
become JS arrays. This means you can translate any example from
[datatables.net](https://datatables.net/examples/) directly to R.

### Translation Rules

| JavaScript            | R                                        |
|-----------------------|------------------------------------------|
| `{ key: value }`      | `list(key = value)`                      |
| `[1, 2, 3]`           | `c(1, 2, 3)` or `list(1, 2, 3)`          |
| `true` / `false`      | `TRUE` / `FALSE`                         |
| `null`                | `NULL`                                   |
| `"string"`            | `"string"`                               |
| `function(d) { ... }` | `htmlwidgets::JS("function(d) { ... }")` |

### Example: JS to R

**JavaScript** (from datatables.net):

``` js
$('#myTable').DataTable({
  pageLength: 25,
  ordering: true,
  language: {
    search: "Filter:",
    lengthMenu: "Show _MENU_ entries"
  },
  columnDefs: [
    { targets: 0, visible: false },
    { targets: [1, 2], className: "text-center" }
  ]
});
```

**R** (with DT2):

``` r

dt2(iris, options = list(
  pageLength = 25,
  ordering   = TRUE,
  language   = list(
    search     = "Filter:",
    lengthMenu = "Show _MENU_ entries"
  ),
  columnDefs = list(
    list(targets = 0, visible = FALSE),
    list(targets = c(1, 2), className = "text-center")
  )
))
```

## Layout — The Complete Guide

DataTables 2 replaced the old `dom` string with `layout`, a structured
way to position elements around the table. This is the most important
change from DataTables 1.x.

### Position grid

    +------------------+------------------+
    | topStart         | topEnd           |
    +------------------+------------------+
    | top (full width)                    |
    +------------------+------------------+
    | top2Start        | top2End          |
    +------------------+------------------+
    |               TABLE                 |
    +------------------+------------------+
    | bottomStart      | bottomEnd        |
    +------------------+------------------+
    | bottom (full width)                 |
    +------------------+------------------+
    | bottom2Start     | bottom2End       |
    +------------------+------------------+

### Available elements

| Element           | Description                                        |
|-------------------|----------------------------------------------------|
| `"search"`        | Search/filter input                                |
| `"paging"`        | Page navigation                                    |
| `"info"`          | “Showing X to Y of Z entries”                      |
| `"pageLength"`    | Entries per page selector                          |
| `"buttons"`       | Buttons toolbar (requires Buttons extension)       |
| `"searchBuilder"` | SearchBuilder (requires extension)                 |
| `"searchPanes"`   | SearchPanes (requires extension)                   |
| `NULL`            | Remove whatever would normally be in that position |

### Default layout

When you don’t specify `layout`, DataTables uses:

``` r

layout = list(
  topStart    = "pageLength",
  topEnd      = "search",
  bottomStart = "info",
  bottomEnd   = "paging"
)
```

### Rearranging

Move search to the left, page length to the right:

``` r

dt2(iris, options = list(
  pageLength = 5,
  layout = list(
    topStart = list(search = list(placeholder = "Filter...")),
    topEnd   = "pageLength"
  )
))
```

### Removing elements

Set any position to `NULL`:

``` r

dt2(iris, options = list(
  pageLength = 10,
  searching = FALSE,
  layout = list(
    topStart  = NULL,      # no page length selector
    topEnd    = NULL,      # no search box
    bottomStart = NULL,    # no info
    bottomEnd = "paging"   # only pagination
  )
))
```

### Multiple elements in one position

Wrap them in a list:

``` r

dt2(iris, options = list(
  pageLength = 5,
  layout = list(
    topStart  = list("pageLength", "info"),
    topEnd    = "search",
    bottomEnd = "paging"
  )
))
```

### Full-width rows

Use `top`, `top2`, `bottom`, `bottom2` for full-width rows:

``` r

dt2(iris, options = list(
  layout = list(
    top       = "search",       # full-width search bar
    topStart  = "pageLength",
    topEnd    = "buttons",
    bottomEnd = "paging"
  )
))
```

### Buttons in layout

Place the Buttons toolbar in any position:

``` r

# Buttons on the left
dt2(iris[1:15, ], options = list(
  buttons = list("copy", "csv", "excel"),
  layout = list(
    topStart  = "buttons",
    topEnd    = "search",
    bottomEnd = "paging"
  )
))
```

``` r

# Buttons on the bottom
dt2(iris[1:15, ], options = list(
  buttons = list("copy", "csv"),
  layout = list(
    topEnd      = "search",
    bottomStart = "buttons",
    bottomEnd   = "paging"
  )
))
```

### Customized search box

``` r

dt2(iris, options = list(
  pageLength = 5,
  layout = list(
    topEnd = list(search = list(
      placeholder = "Type to filter...",
      text = "Search:"
    ))
  )
))
```

### Complete custom layout

``` r

dt2(mtcars[1:20, ], options = list(
  pageLength = 10,
  buttons = list(
    list(extend = "collection", text = "Export \u25BC",
         buttons = list("copyHtml5", "csvHtml5", "excelHtml5")),
    list(extend = "colvis", text = "Columns")
  ),
  layout = list(
    topStart    = "buttons",
    topEnd      = list(search = list(placeholder = "Filter...")),
    bottomStart = "info",
    bottomEnd   = "paging"
  )
))
```

### Migrating from `dom`

If you’re coming from DataTables 1.x or the DT package:

| Old `dom` | New `layout` |
|----|----|
| `"frtip"` | (default — no need to specify) |
| `"tp"` | `list(topStart = NULL, topEnd = NULL, bottomStart = NULL, bottomEnd = "paging")` |
| `"Bfrtip"` | `list(topStart = "buttons")` |
| `"lfBrtip"` | `list(topStart = list("pageLength", "buttons"))` |

DT2 will automatically convert `dom` strings containing `"B"` to the
`layout` equivalent, but using `layout` directly is recommended.

## Using `htmlwidgets::JS()` for Callbacks

Whenever DataTables expects a JavaScript function, wrap it in
[`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html):

``` r

dt2(iris, options = list(
  pageLength = 5,
  createdRow = htmlwidgets::JS("
    function(row, data, dataIndex) {
      if (data['Sepal.Length'] > 5) {
        row.style.backgroundColor = '#fff3cd';
      }
    }
  ")
))
```

### Common Callbacks

| DataTables Option | Purpose                          |
|-------------------|----------------------------------|
| `createdRow`      | Modify each row after creation   |
| `initComplete`    | Run code after table initializes |
| `drawCallback`    | Run code after each draw         |
| `headerCallback`  | Modify the header after draw     |
| `footerCallback`  | Modify the footer after draw     |
| `columns.render`  | Custom cell rendering            |

## Column Renderers

### Built-in DataTables Renderers

DataTables v2 provides built-in renderers accessible via
`DataTable.render.*`:

``` r

dt2(mtcars[1:10, c("mpg", "hp", "wt")], options = list(
  columnDefs = list(
    list(
      targets = 0,
      render = htmlwidgets::JS("DataTable.render.number('.', ',', 1, '', ' mpg')")
    ),
    list(
      targets = 1,
      render = htmlwidgets::JS("DataTable.render.number(',', '.', 0, '', ' hp')")
    )
  )
))
```

### Custom Render Function

``` r

progress_render <- htmlwidgets::JS("
  function(data, type, row, meta) {
    if (type !== 'display') return data;
    var pct = Math.min(100, Math.max(0, parseFloat(data)));
    var color = pct > 70 ? '#198754' : (pct > 40 ? '#ffc107' : '#dc3545');
    return '<div style=\"background:#eee;border-radius:4px;overflow:hidden\">' +
           '<div style=\"width:' + pct + '%;background:' + color +
           ';height:14px;border-radius:4px\"></div></div>';
  }
")

df <- data.frame(
  task     = c("Design", "Backend", "Testing", "Deploy"),
  progress = c(85, 60, 30, 95)
)

dt2(df, options = list(
  pageLength = 10,
  columnDefs = list(
    list(targets = 1, render = progress_render)
  )
))
```

## Internationalization (i18n)

### Inline language object

``` r

dt2(iris[1:10, ], options = list(
  pageLength = 5,
  language = list(
    search       = "Buscar:",
    lengthMenu   = "Mostrar _MENU_ registros",
    info         = "Mostrando _START_ a _END_ de _TOTAL_",
    paginate     = list(
      first    = "<<",
      previous = "<",
      `next`   = ">",
      last     = ">>"
    ),
    zeroRecords  = "Nenhum registro encontrado",
    emptyTable   = "Tabela vazia"
  )
))
```

### CDN language URL

DataTables provides ready-made translation files for 70+ languages:

``` r

dt2(iris, options = list(
  language = list(
    url = "https://cdn.datatables.net/plug-ins/2.3.4/i18n/pt-BR.json"
  )
))
```

## Debugging

Open the browser console and look for `[DT2]` log messages. Access the
DataTables API object directly via JavaScript:

``` js
// In browser console:
var el = document.getElementById('my_table');
var api = el._dt2;
api.page.info();      // pagination state
api.order();          // current ordering
api.search();         // current search term
api.rows().data();    // all row data
```
