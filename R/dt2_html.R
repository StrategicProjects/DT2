#' Allow raw HTML rendering via `columns.render`
#'
#' @description Mark columns to render raw HTML using a JS render function.
#' @param options Options list.
#' @param cols Names or 1-based indices.
#' @param js_render JS function (via [htmlwidgets::JS]) with signature `(data, type, row, meta)`
#'   returning a string of HTML when `type == "display"`.
#' @return Updated `options`.
#' @export
dt2_cols_html <- function(options = list(), cols, js_render) {
  if (is.character(cols)) cols <- match(cols, options$columns)
  cds <- lapply(cols, function(i) list(
    targets = i - 1L,
    render  = js_render
  ))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

#' Simple HTML template per column (replace `{{VAL}}`)
#'
#' @param options Options list.
#' @param col Name or index of target column.
#' @param template HTML string with `{{VAL}}` placeholder.
#' @return Updated `options`.
#' @export
dt2_col_template <- function(options = list(), col, template) {
  if (is.character(col)) col <- match(col, options$columns)
  js <- htmlwidgets::JS(
    sprintf(
      "function(d,t,row,meta){ if(t!=='display') return d; var html=%s; return html.replace(/\\{\\{VAL\\}\\}/g, d); }",
      jsonlite::toJSON(template, auto_unbox = TRUE)
    )
  )
  dt2_cols_html(options, col, js)
}
