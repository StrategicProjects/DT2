#' Checkbox input per row
#'
#' @param options Options list.
#' @param col Target column (name or 1-based index).
#' @param input_id_prefix Prefix for element ids (e.g., "row_chk_").
#' @param value_col Optional boolean column to define initial state.
#' @return Updated `options`.
#' @export
dt2_col_checkbox <- function(options = list(), col, input_id_prefix = "row_chk_", value_col = NULL) {
  if (is.character(col)) col <- match(col, options$columns)

  # HÍBRIDO: lê por índice (array) OU por nome (objeto)
  if (is.null(value_col)) {
    value_js <- "false"
    name_js  <- "null"
  } else {
    if (is.character(value_col)) {
      idx  <- match(value_col, options$columns)
      name <- value_col
    } else {
      idx  <- as.integer(value_col)
      name <- options$columns[[idx]]
    }
    value_js <- sprintf("(Array.isArray(row) ? row[%d] : row[%s])",
                        idx - 1L,
                        jsonlite::toJSON(name, auto_unbox = TRUE))
  }

  js <- htmlwidgets::JS(sprintf(
    "function(d,t,row,meta){ if(t!=='display') return d;
       var rid = '%s' + (meta.row+1);
       var checked = %s ? ' checked' : '';
       return '<input type=\"checkbox\" class=\"dt2-row-checkbox form-check-input\" id=\"'+rid+'\"'+checked+'/>'; }",
    input_id_prefix, value_js))

  dt2_cols_html(options, col, js)
}

#' Action button per row
#'
#' @param options Options list.
#' @param col Target column (name or 1-based index).
#' @param label Button label.
#' @param input_id_prefix Prefix for element ids (e.g., "row_btn_").
#' @return Updated `options`.
#' @export
dt2_col_button <- function(options = list(), col, label = "Action", input_id_prefix = "row_btn_") {
  if (is.character(col)) col <- match(col, options$columns)
  js <- htmlwidgets::JS(sprintf(
    "function(d,t,row,meta){ if(t!=='display') return d;
       var rid = '%s' + (meta.row+1);
       return '<button type=\"button\" class=\"dt2-row-button btn btn-sm btn-primary\" id=\"'+rid+'\">%s</button>';
     }", input_id_prefix, htmltools::htmlEscape(label)))
  dt2_cols_html(options, col, js)
}
