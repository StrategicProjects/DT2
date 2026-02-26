# Enable Buttons (extension) and define buttons

Uses the modern DataTables 2.x `layout` API (not the deprecated `dom`).

## Usage

``` r
dt2_use_buttons(
  options = list(),
  buttons = c("copy", "csv", "excel", "print"),
  position = "topEnd",
  button_class = NULL
)
```

## Arguments

- options:

  Options list.

- buttons:

  Vector of button ids (e.g., c("copy","csv","excel","print","colvis")).

- position:

  Where to place buttons in the layout. One of `"topEnd"` (default),
  `"topStart"`, `"bottomEnd"`, `"bottomStart"`.

- button_class:

  CSS class for buttons (e.g., `"btn btn-sm btn-primary"`). If `NULL`,
  uses the theme default (`"btn btn-sm btn-outline-secondary"`). Applied
  per-button via `className`.

## Value

Updated `options`.
