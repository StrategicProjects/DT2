# ---- Theme presets -----------------------------------------------------------

#' @keywords internal
.dt2_presets <- function() {
  list(
    default = list(
      striped = TRUE, hover = TRUE, compact = TRUE,
      font_scale = 0.8, style = "bootstrap5",
      button_class = "btn btn-sm btn-outline-secondary"
    ),
    clean = list(
      striped = TRUE, hover = TRUE, compact = FALSE,
      font_scale = 0.85, style = "bootstrap5",
      button_class = "btn btn-sm btn-outline-secondary"
    ),
    minimal = list(
      striped = FALSE, hover = FALSE, compact = FALSE,
      font_scale = 0.9, style = "bootstrap5",
      button_class = "btn btn-sm btn-outline-secondary"
    ),
    compact = list(
      striped = TRUE, hover = TRUE, compact = TRUE,
      font_scale = 0.75, style = "bootstrap5",
      button_class = "btn btn-sm btn-outline-secondary"
    )
  )
}


# ---- dt2_theme(): reusable theme objects ------------------------------------

#' Create a reusable DT2 theme
#'
#' @description
#' Creates a theme object that can be passed to [dt2()] via the `theme`
#' parameter. Useful when you want the same look across many tables.
#'
#' For quick one-off styling, you can also pass arguments directly to
#' [dt2()] (e.g., `dt2(iris, striped = FALSE)`).
#'
#' @param preset A named preset to start from: `"default"`, `"clean"`,
#'   `"minimal"`, or `"compact"`. Remaining arguments override the preset.
#' @param striped Logical; alternate row colours.
#' @param hover Logical; highlight rows on hover.
#' @param compact Logical; reduce cell padding.
#' @param font_scale Numeric; font-size multiplier (e.g., 0.85 = 85%).
#' @param style Styling framework: `"bootstrap5"` (default) or `"core"`
#'   (plain DataTables).
#' @param button_class CSS class string for Buttons extension buttons.
#'   Default: `"btn btn-sm btn-outline-secondary"`. See Bootstrap 5
#'   button classes for options (e.g., `"btn btn-sm btn-primary"`).
#'
#' @return A `dt2_theme` object (a named list).
#' @export
#'
#' @examples
#' # Create and reuse
#' my_theme <- dt2_theme("clean", compact = TRUE)
#' dt2(iris, theme = my_theme)
#' dt2(mtcars, theme = my_theme)
#'
#' # Custom button style
#' dt2_theme("default", button_class = "btn btn-sm btn-primary")
#'
#' # Presets
#' dt2_theme("minimal")
#' dt2_theme("compact")
dt2_theme <- function(preset = "default",
                      striped = NULL, hover = NULL, compact = NULL,
                      font_scale = NULL, style = NULL,
                      button_class = NULL) {

  # ---- Backward compat: old API was dt2_theme(options_list, striped=T, ...) ----
  if (is.list(preset)) {
    options <- preset
    th <- .dt2_presets()[["default"]]
    if (!is.null(striped))    th$striped    <- isTRUE(striped)
    if (!is.null(hover))      th$hover      <- isTRUE(hover)
    if (!is.null(compact))    th$compact    <- isTRUE(compact)
    if (!is.null(font_scale)) th$font_scale <- font_scale
    if (!is.null(style))      th$style      <- match.arg(style, c("bootstrap5", "core"))
    options$dt2_theme <- th
    return(options)
  }

  presets <- .dt2_presets()
  base <- presets[[preset %||% "default"]]
  if (is.null(base)) {
    stop("Unknown theme preset: '", preset,
         "'. Available: ", paste(names(presets), collapse = ", "),
         call. = FALSE)
  }

  # Override with explicit args
  if (!is.null(striped))      base$striped      <- isTRUE(striped)
  if (!is.null(hover))        base$hover        <- isTRUE(hover)
  if (!is.null(compact))      base$compact      <- isTRUE(compact)
  if (!is.null(font_scale))   base$font_scale   <- font_scale
  if (!is.null(style))        base$style        <- match.arg(style, c("bootstrap5", "core"))
  if (!is.null(button_class)) base$button_class <- button_class

  structure(base, class = "dt2_theme")
}

#' @export
print.dt2_theme <- function(x, ...) {
  cat("DT2 theme:\n")
  cat("  striped      =", x$striped, "\n")
  cat("  hover        =", x$hover, "\n")
  cat("  compact      =", x$compact, "\n")
  cat("  font_scale   =", x$font_scale, "\n")
  cat("  style        =", x$style, "\n")
  cat("  button_class =", x$button_class, "\n")
  invisible(x)
}


# ---- dt2(): main function ---------------------------------------------------

#' Create a DT2 DataTable widget
#'
#' @description
#' The main function for creating interactive DataTables.
#' Works standalone (R Markdown, Quarto, Viewer) and inside Shiny.
#'
#' **Styling** is controlled directly via `theme`, `striped`, `hover`,
#' `compact`, `font_scale` -- or a CSS `class` string for full control.
#'
#' **DataTables configuration** goes in `options` (1:1 mapping to the
#' JavaScript API). The two concerns are cleanly separated.
#'
#' @param data A `data.frame`, `tibble`, or `matrix`.
#' @param theme A theme preset name (`"default"`, `"clean"`, `"minimal"`,
#'   `"compact"`) or a [dt2_theme()] object. Default: `"default"`.
#' @param striped,hover,compact Logical; override the theme.
#'   `NULL` (default) = use theme value.
#' @param font_scale Numeric; override the theme font-scale.
#'   `NULL` (default) = use theme value.
#' @param style Styling framework: `"bootstrap5"` (default) or `"core"`.
#' @param class Optional CSS class string (e.g., `"table table-dark"`).
#'   If provided, overrides all theme-generated classes.
#' @param button_class CSS class for Buttons extension buttons.
#'   Default: `"btn btn-sm btn-outline-secondary"`.
#'   Examples: `"btn btn-sm btn-primary"`, `"btn btn-sm btn-outline-dark"`.
#' @param responsive Logical; enable the Responsive extension so the table
#'   fills 100\% width and adapts to narrow screens by collapsing columns.
#'   Default: `TRUE`. Set `FALSE` to disable.
#' @param options List of DataTables options. See
#'   \url{https://datatables.net/reference/option/}.
#' @param extensions Character vector of extensions to load
#'   (e.g., `c("Buttons", "Select")`). Auto-detected from `options`
#'   when `NULL`.
#' @param width,height CSS dimensions.
#' @param elementId Optional HTML element ID.
#'
#' @return An `htmlwidget` object.
#' @export
#'
#' @examples
#' # Just works — beautiful defaults
#' dt2(iris)
#'
#' # Override style inline
#' dt2(iris, striped = FALSE)
#' dt2(iris, font_scale = 0.85, compact = FALSE)
#'
#' # Theme presets
#' dt2(iris, theme = "minimal")
#' dt2(iris, theme = "compact")
#'
#' # Reusable theme
#' my_theme <- dt2_theme("clean", compact = TRUE)
#' dt2(iris, theme = my_theme)
#'
#' # Override a preset
#' dt2(iris, theme = "minimal", striped = TRUE)
#'
#' # CSS class override (power users)
#' dt2(iris, class = "table table-bordered table-dark")
#'
#' # DataTables options (separate from styling)
#' dt2(iris, options = list(pageLength = 5, searching = FALSE))
#'
#' # Disable responsive (fixed-width columns)
#' dt2(iris, responsive = FALSE)
#'
#' # Everything composes
#' dt2(mtcars,
#'     theme = "clean",
#'     compact = TRUE,
#'     options = list(pageLength = 25))
#'
#' # Buttons
#' dt2(mtcars, options = list(
#'   buttons = list("copy", "csv", "excel"),
#'   layout = list(topEnd = "buttons")
#' ))
#'
#' # Custom button style
#' dt2(mtcars,
#'     button_class = "btn btn-sm btn-primary",
#'     options = list(
#'       buttons = list("copy", "csv", "excel"),
#'       layout = list(topEnd = "buttons")
#'     ))
dt2 <- function(data,
                # ---- styling ----
                theme        = "default",
                striped      = NULL,
                hover        = NULL,
                compact      = NULL,
                font_scale   = NULL,
                style        = NULL,
                class        = NULL,
                button_class = NULL,
                # ---- behavior ----
                responsive = TRUE,
                # ---- DataTables config ----
                options    = list(),
                extensions = NULL,
                # ---- widget ----
                width = "100%", height = NULL, elementId = NULL) {

  # ---- Resolve theme ---------------------------------------------------------
  # Priority: direct args > theme object/preset > defaults

  if (inherits(theme, "dt2_theme")) {
    th <- as.list(theme)
  } else if (is.character(theme) && length(theme) == 1) {
    presets <- .dt2_presets()
    th <- presets[[theme]]
    if (is.null(th)) {
      stop("Unknown theme: '", theme,
           "'. Available: ", paste(names(presets), collapse = ", "),
           call. = FALSE)
    }
  } else {
    th <- .dt2_presets()[["default"]]
  }

  # Override with direct args (NULL = use theme value)
  if (!is.null(striped))      th$striped      <- isTRUE(striped)
  if (!is.null(hover))        th$hover        <- isTRUE(hover)
  if (!is.null(compact))      th$compact      <- isTRUE(compact)
  if (!is.null(font_scale))   th$font_scale   <- font_scale
  if (!is.null(style))        th$style        <- match.arg(style, c("bootstrap5", "core"))
  if (!is.null(button_class)) th$button_class <- button_class

  # CSS class override
  th$class <- class  # NULL or string

  # Framework settings
  bs <- th$style %||% "bootstrap5"
  include_bs <- (bs == "bootstrap5")

  # ---- Backward compat: clean up old dt2_theme in options --------------------
  if (!is.null(options$dt2_theme)) {
    old <- options$dt2_theme
    if (is.null(striped) && !is.null(old$striped))       th$striped    <- old$striped
    if (is.null(hover) && !is.null(old$hover))           th$hover      <- old$hover
    if (is.null(compact) && !is.null(old$compact))       th$compact    <- old$compact
    if (is.null(font_scale) && !is.null(old$font_scale)) th$font_scale <- old$font_scale
    options$dt2_theme <- NULL
  }

  # ---- Inject theme for JS side ---------------------------------------------
  options$dt2_theme <- list(
    bs           = bs,
    striped      = th$striped,
    hover        = th$hover,
    compact      = th$compact,
    font_scale   = th$font_scale,
    class        = th$class,
    button_class = th$button_class
  )

  # ---- Responsive default -----------------------------------------------------
  # Enable by default so tables fill 100% width and adapt to screen size.
  # User can opt out: dt2(iris, responsive = FALSE)
  if (isTRUE(responsive) && is.null(options$responsive)) {
    options$responsive <- TRUE
  } else if (identical(responsive, FALSE)) {
    options$responsive <- NULL  # ensure extension is not loaded
  }

  # ---- Extensions auto-detect ------------------------------------------------
  if (is.null(extensions)) {
    extensions <- .dt2_detect_extensions(options)
  }

  # ---- Build payload ---------------------------------------------------------
  x <- list(
    data    = data,
    options = options
  )

  deps <- dt2_deps(
    bs         = bs,
    include_bs = include_bs,
    extensions = extensions
  )

  htmlwidgets::createWidget(
    name = "dt2",
    x, width, height,
    package = "DT2",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth  = "100%",
      defaultHeight = "auto",
      knitr.defaultWidth  = "100%",
      knitr.defaultHeight = "auto",
      browser.fill  = FALSE,
      viewer.fill   = FALSE,
      knitr.figure  = FALSE,
      padding       = 0
    ),
    dependencies = deps
  )
}
