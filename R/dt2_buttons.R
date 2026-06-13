#' Configure DataTables Buttons and (optionally) move them to a custom container
#'
#' @param options A DT2 `options` list you are building.
#' @param buttons Character vector with button names (e.g. `"copyHtml5"`, `"csvHtml5"`, `"excelHtml5"`, `"pdfHtml5"`, `"print"`).
#'   You can also pass a list with full button objects.
#' @param target Optional CSS selector (e.g. `"#btn-slot"` or `".my-toolbar"`) to receive the
#'   buttons container. If provided, DT2 will move the rendered buttons to that container after init.
#' @return The modified `options` list.
#' @details Requires the **Buttons** extension. For CSV/Excel/PDF you also need **JSZip** and **pdfMake** (incl. `vfs_fonts`).
#'
#'   Prefer [dt2_use_buttons()] for the common case: it takes simple button ids,
#'   styles them with a CSS class, and places them in the layout. Use
#'   `dt2_buttons()` when you need full button objects or want to move the
#'   rendered buttons into a custom container via `target`.
#' @seealso [dt2_use_buttons()]
#' @export
dt2_buttons <- function(options = list(),
                        buttons = c("copyHtml5", "csvHtml5", "excelHtml5", "pdfHtml5", "print"),
                        target  = NULL) {
  options$buttons <- as.list(buttons)
  if (!is.null(target)) options$dt2_buttons_target <- target
  options
}
