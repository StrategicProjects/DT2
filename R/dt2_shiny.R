#' Shiny output for DT2
#'
#' Place a DT2 table in a Shiny UI.
#'
#' @param outputId Output ID (must match the `render_dt2()` call in server).
#' @param width,height CSS dimensions.
#' @return An `htmlwidgets` Shiny output (HTML container) suitable for
#'   inclusion in a Shiny UI definition.
#' @export
dt2_output <- function(outputId, width = "100%", height = "auto") {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required for dt2_output().", call. = FALSE)
  }
  htmlwidgets::shinyWidgetOutput(outputId, "dt2", width, height, package = "DT2")
}

#' Shiny render function for DT2
#'
#' Render a DT2 table in a Shiny server function.
#'
#' @param expr Expression returning a [dt2()] widget.
#' @param env,quoted Standard `shinyRenderWidget` arguments.
#' @return A Shiny render function (closure produced by
#'   [htmlwidgets::shinyRenderWidget()]) that emits a DT2 widget.
#' @export
render_dt2 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required for render_dt2().", call. = FALSE)
  }
  if (!quoted) expr <- substitute(expr)
  htmlwidgets::shinyRenderWidget(expr, dt2_output, env, quoted = TRUE)
}

#' Observe DataTables events published by dt2.js
#'
#' Listen for table events (init, draw, order, search, page, select, deselect).
#'
#' @param input Shiny input object.
#' @param id Widget ID.
#' @param handler Function with signature `(event, type, indexes, rowData)`.
#' @return No return value, called for side effects. Sets up a Shiny
#'   observer that calls `handler` whenever the table emits an event.
#' @export
observe_dt2_events <- function(input, id, handler) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required.", call. = FALSE)
  }
  shiny::observeEvent(input[[paste0(id, "_event")]], {
    evt <- input[[paste0(id, "_event")]]
    handler(evt$event, evt$type, evt$indexes, evt$rowData)
  }, ignoreInit = TRUE)
}

#' Access the current state snapshot of a DT2 table
#'
#' Returns a list with `reason`, `order`, `search`, `page`, `selected`,
#' `rows_all`, `rows_current`, `rows_selected` and `state` reflecting the
#' current client-side table state.
#'
#' @details
#' The widget pushes `input$<id>_state` on every `init`, `draw`, `order`,
#' `search`, `page`, `select` and `deselect` event. Besides that snapshot, it
#' also sets three standalone inputs with the same names as the `DT` package,
#' all **1-based** row indices into the original data:
#'
#' * `input$<id>_rows_all` -- rows that survive the current filters (global
#'   search and per-column searches, e.g. from the ColumnControl extension),
#'   in display order.
#' * `input$<id>_rows_current` -- the rows shown on the current page.
#' * `input$<id>_rows_selected` -- the selected rows (Select extension).
#'
#' The same vectors are available inside the snapshot as `rows_all`,
#' `rows_current` and `rows_selected`. The legacy `selected` element is kept
#' unchanged (0-based, as DataTables reports it).
#'
#' With server-side processing the client only holds the current page, so
#' `rows_all` / `rows_current` are taken from the server response: the default
#' [dt2_ssp_handler()] ships them unless `rows_all = FALSE` (see
#' [dt2_bind_server()]); a custom handler must return `dt2_rows_all` /
#' `dt2_rows_current` itself, otherwise those inputs are `NULL`.
#'
#' @param input Shiny input object.
#' @param id Widget ID.
#' @return A list with the current table state.
#' @export
dt2_state <- function(input, id) {
  input[[paste0(id, "_state")]]
}
