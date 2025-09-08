#' Format numeric columns (DataTables renderer: number)
#'
#' Add a number renderer to one or more columns using
#' DataTables' built-in \code{DataTable.render.number}.
#'
#' @param options List of options (returned, with \code{columnDefs} updated).
#' @param col_specs Column names or 1-based indices to format.
#' @param thousands Thousands separator (character or \code{NULL} for auto).
#' @param decimal Decimal separator (character or \code{NULL} for auto).
#' @param digits Number of decimal places.
#' @param prefix,prefix_right String to prepend/append (e.g., currency symbol).
#'
#' @return Modified \code{options}.
#' @examples
#' \dontrun{
#' opts <- list(columns = names(iris))
#' opts <- dt2_format_number(opts, "Sepal.Length", thousands = ".", decimal = ",",
#'                           digits = 2, prefix = "", prefix_right = "")
#' }
#' @export
dt2_format_number <- function(options = list(), col_specs,
                              thousands = NULL, decimal = NULL,
                              digits = 0, prefix = "", prefix_right = "") {
  #`%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)
  # DataTables v2 sugere DataTable.render.number(...)
  # https://datatables.net/manual/data/renderers
  js <- htmlwidgets::JS(
    sprintf("DataTable.render.number(%s,%s,%d,%s,%s)",
            if (is.null(thousands)) "null" else sprintf("'%s'", thousands),
            if (is.null(decimal))   "null" else sprintf("'%s'", decimal),
            as.integer(digits),
            sprintf("'%s'", prefix),
            sprintf("'%s'", prefix_right))
  )
  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

#' Format date/time columns (DataTables renderer: datetime)
#'
#' Use DataTables' built-in \code{DataTable.render.datetime} to transform
#' date/time strings for display (and preserve sortability).
#'
#' @param options List of options (returned with \code{columnDefs} updated).
#' @param col_specs Column names or 1-based indices.
#' @param from Input format (e.g., \code{"YYYY-MM-DD"} or ISO8601 by default).
#' @param to Output format (e.g., \code{"DD/MM/YYYY"}).
#' @param locale Optional locale (e.g., \code{"pt-BR"}).
#' @param def Optional default output if input is invalid.
#'
#' @return Modified \code{options}.
#' @examples
#' \dontrun{
#' opts <- list(columns = c("when", "val"))
#' opts <- dt2_format_datetime(opts, "when", from = "YYYY-MM-DD", to = "DD/MM/YYYY", locale = "pt-BR")
#' }
#' @export
dt2_format_datetime <- function(options = list(), col_specs,
                                from = NULL, to = "DD/MM/YYYY",
                                locale = NULL, def = NULL) {
  #`%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)

  args <- c(
    if (is.null(from)) "undefined" else sprintf("'%s'", from),
    if (is.null(to))   "undefined" else sprintf("'%s'", to),
    if (is.null(locale)) "undefined" else sprintf("'%s'", locale),
    if (is.null(def))    "undefined" else sprintf("'%s'", def)
  )
  # ver docs: https://datatables.net/plug-ins/dataRender/datetime  + manual de renderers
  js <- htmlwidgets::JS(sprintf("DataTable.render.datetime(%s)", paste(args, collapse = ", ")))
  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

#' Attach a raw JS render function to columns
#'
#' Provide a custom JS renderer for one or more columns. Use this when
#' you need fine control over \code{columns.render}, including returning
#' different outputs based on \code{type} (display/sort/filter/type).
#'
#' @param options List returned, with \code{columnDefs} appended.
#' @param col_specs Column names or indices.
#' @param js_render A \code{htmlwidgets::JS()} function of signature
#'   \code{function(data, type, row, meta) { ... }}.
#'
#' @return Modified \code{options}.
#' @seealso \url{https://datatables.net/reference/option/columns.render}
#' @export
dt2_cols_render_js <- function(options = list(), col_specs, js_render) {
  #`%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)
  stopifnot(inherits(js_render, "JS_EVAL"))
  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js_render))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

#' Orthogonal render (display/sort/filter/type) per column
#'
#' Supply different renderers for each orthogonal data request. Pass an
#' object with keys \code{display}, \code{sort}, \code{filter}, \code{type}
#' (all optional). Each value must be a JS function.
#'
#' @param options Options list to modify.
#' @param col_specs Column names or indices.
#' @param display Optional JS renderer for UI display.
#' @param sort Optional JS renderer used for ordering.
#' @param filter Optional JS renderer used for searching.
#' @param type Optional JS renderer used for type detection.
#'
#' @return Modified \code{options}.
#' @examples
#' \dontrun{
#' opts <- list(columns = names(iris))
#' opts <- dt2_cols_render_orthogonal(
#'   opts, "Sepal.Length",
#'   display = DT2::JS("function(d,t,row,meta){ return d + ' cm'; }"),
#'   sort    = DT2::JS("function(d,t,row,meta){ return parseFloat(d); }")
#' )
#' }
#' @export
dt2_cols_render_orthogonal <- function(options = list(), col_specs,
                                       display = NULL, sort = NULL,
                                       filter = NULL, type = NULL) {
  #`%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)

  # Monta um objeto {display, sort, filter, type} só com o que foi passado
  parts <- c(
    if (!is.null(display)) sprintf("display:%s", as.character(display)) else NULL,
    if (!is.null(sort))    sprintf("sort:%s",    as.character(sort))    else NULL,
    if (!is.null(filter))  sprintf("filter:%s",  as.character(filter))  else NULL,
    if (!is.null(type))    sprintf("type:%s",    as.character(type))    else NULL
  )
  stopifnot(length(parts) > 0)
  js <- htmlwidgets::JS(sprintf("{%s}", paste(parts, collapse = ",")))

  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}


#' Abbreviate large numbers with fixed decimals (k / M / B)
#'
#' Adds a `columns.render` function that displays numbers as 1.2k, 3.4M, etc.
#' This renderer **lets you control** the number of decimal places via `digits`.
#' Use this when you want a fixed, compact style independent of locale rules.
#'
#' @param options A DataTables options list to be modified.
#' @param col_specs Column names or 1-based indices to format.
#' @param digits Integer, decimal places for the abbreviated display (default 1).
#' @param locale Optional BCP-47 locale string (e.g. "pt-BR"). If provided,
#'   the non-abbreviated part uses `toLocaleString(locale)` for grouping.
#'
#' @return The modified `options` list.
#' @export
#' @examples
#' opts <- list(columns = names(mtcars))
#' opts <- dt2_format_number_abbrev(opts, c("hp","qsec"), digits = 1, locale = "pt-BR")
dt2_format_number_abbrev <- function(options = list(), col_specs, digits = 1, locale = NULL) {
  `%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)

  # JS renderer: abrevia com k/M/B e aplica toLocaleString(locale) na parte inteira se locale fornecido
  js <- if (is.null(locale) || !nzchar(locale)) {
    htmlwidgets::JS(sprintf(
      "function(d, t, row, meta){
         if (t !== 'display' && t !== 'filter') return d;
         var n = Number(d);
         if (!isFinite(n)) return d;
         var abs = Math.abs(n), sign = n < 0 ? '-' : '';
         function fmt(x){ return x.toFixed(%d); }
         if (abs >= 1e9)  return sign + fmt(abs/1e9) + 'B';
         if (abs >= 1e6)  return sign + fmt(abs/1e6) + 'M';
         if (abs >= 1e3)  return sign + fmt(abs/1e3) + 'k';
         return n.toFixed(%d);
       }", digits, digits))
  } else {
    htmlwidgets::JS(sprintf(
      "function(d, t, row, meta){
         if (t !== 'display' && t !== 'filter') return d;
         var n = Number(d);
         if (!isFinite(n)) return d;
         var abs = Math.abs(n), sign = n < 0 ? '-' : '';
         function fmt(x){ return Number(x.toFixed(%d)).toLocaleString('%s'); }
         if (abs >= 1e9)  return sign + fmt(abs/1e9) + 'B';
         if (abs >= 1e6)  return sign + fmt(abs/1e6) + 'M';
         if (abs >= 1e3)  return sign + fmt(abs/1e3) + 'k';
         return n.toLocaleString('%s', { minimumFractionDigits: %d, maximumFractionDigits: %d });
       }", digits, locale, locale, digits, digits))
  }

  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

#' Format a date/time using DataTables' datetime renderer, with locale
#' @param from input format (e.g. 'YYYY-MM-DDTHH:mm:ssZ' or null for ISO)
#' @param to   output format (e.g. 'L LTS') - ver moment.js
#' @param locale e.g. 'pt-br'
#' @export
dt2_format_time_format <- function(options = list(), col_specs,
                                   from = NULL, to = "L", locale = "pt-br") {
  `%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)

  # ativa locale no cliente (fallback para renders que usem moment direto)
  options$`_momentLocale` <- locale

  # DataTables v2: DataTable.render.datetime(from, to, locale)
  renderer_call <- if (is.null(from)) {
    sprintf("DataTable.render.datetime('%s','%s')", to, locale)
  } else {
    sprintf("DataTable.render.datetime('%s','%s','%s')", from, to, locale)
  }
  render <- htmlwidgets::JS(renderer_call)

  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = render))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

#' Relative time using moment.fromNow(), with locale
#' @param options list of options (returned updated)
#' @param col_specs names or indices to format
#' @param locale e.g. "pt-br" (requires moment-with-locales)
#' @export
dt2_format_time_relative <- function(options = list(), col_specs, locale = "pt-br") {
  `%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)

  # ativa locale no cliente (usado por dt2.js)
  options$`_momentLocale` <- locale

  render_js <- htmlwidgets::JS(
    sprintf("
function(d, t, row, meta){
  if (d == null || d === '') return d;
  try {
    if (window.moment){
      var m = moment(d);
      if (m.isValid()) return m.fromNow(); // usa locale já ativo
    }
  } catch(e){}
  return d;
}"
    )
  )

  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = render_js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}

