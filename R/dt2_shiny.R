#' Shiny output for DT2
#'
#' Place a DT2 table in a Shiny UI.
#'
#' @param outputId Output ID (must match the `render_dt2()` call in server).
#' @param width,height CSS dimensions.
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
#' Returns a list with `reason`, `order`, `search`, `page`, `selected`, `state`
#' reflecting the current client-side table state.
#'
#' @param input Shiny input object.
#' @param id Widget ID.
#' @return A list with the current table state.
#' @export
dt2_state <- function(input, id) {
  input[[paste0(id, "_state")]]
}
