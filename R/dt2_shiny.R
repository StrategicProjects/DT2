#' Shiny output for DT2
#' @param outputId Output id.
#' @param width,height Size.
#' @export
dt2_output <- function(outputId, width = '100%', height = 'auto') {
  htmlwidgets::shinyWidgetOutput(outputId, 'dt2', width, height, package = 'DT2')
}

#' Shiny render for DT2
#' @param expr Expression returning [dt2()].
#' @param env,quoted Standard shinyRenderWidget args.
#' @export
render_dt2 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) expr <- substitute(expr)
  htmlwidgets::shinyRenderWidget(expr, dt2_output, env, quoted = TRUE)
}

#' Observe DataTables events published by dt2.js
#'
#' @param input Shiny input.
#' @param id Widget id.
#' @param handler Function `(event, type, indexes, rowData)`.
#' @export
observe_dt2_events <- function(input, id, handler) {
  shiny::observeEvent(input[[paste0(id, "_event")]], {
    evt <- input[[paste0(id, "_event")]]
    handler(evt$event, evt$type, evt$indexes, evt$rowData)
  }, ignoreInit = TRUE)
}

#' Access the current state snapshot of a DT2 table
#'
#' @param input Shiny input.
#' @param id Widget id.
#' @return A list with `reason`, `order`, `search`, `page`, `selected`, `state`.
#' @export
dt2_state <- function(input, id) {
  input[[paste0(id, "_state")]]
}
