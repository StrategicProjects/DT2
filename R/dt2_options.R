#' Define initial ordering (option `order`)
#' @param options Options list.
#' @param ... Vectors like `c(col, "asc"/"desc")`. `col` may be name or 1-based index.
#' @return Updated `options`.
#' @export
dt2_order <- function(options = list(), ...) {
  ord <- lapply(list(...), function(x) {
    idx <- if (is.character(x[[1]])) match(x[[1]], options$columns) else as.integer(x[[1]])
    list(idx - 1L, x[[2]])
  })
  options$order <- ord
  options
}

#' Set global search (option `search`)
#' @param options Options list.
#' @param value Text.
#' @param regex,smart,caseInsensitive Search flags.
#' @return Updated `options`.
#' @export
dt2_search_global <- function(options = list(), value, regex = FALSE, smart = TRUE, caseInsensitive = TRUE) {
  options$search <- list(value = value, regex = regex, smart = smart, caseInsensitive = caseInsensitive)
  options
}

#' Enable Buttons (extension) and define buttons
#' @param options Options list.
#' @param buttons Vector of button ids (e.g., c("copy","csv","excel","print","colvis")).
#' @return Updated `options`.
#' @export
dt2_use_buttons <- function(options = list(), buttons = c("copy","csv","excel","print")) {
  options$dom     <- options$dom %||% "Bfrtip"
  options$buttons <- buttons
  options
}

#' Language helper (either list or JSON url)
#' @param options Options list.
#' @param lang_list Named list of language keys.
#' @param lang_url URL to a JSON translation file.
#' @return Updated `options`.
#' @export
dt2_language <- function(options = list(), lang_list = NULL, lang_url = NULL) {
  if (!is.null(lang_url)) {
    options$language <- list(url = lang_url)
  } else if (!is.null(lang_list) && is.list(lang_list)) {
    options$language <- lang_list
  }
  options
}

#' Column widths (CSS)
#' @param options Options list.
#' @param map_named Named character vector: c(Col="120px", ...).
#' @return Updated `options`.
#' @export
dt2_cols_width <- function(options = list(), map_named) {
  options$columnDefs <- c(options$columnDefs %||% list(),
                          lapply(names(map_named), function(nm) {
                            i <- match(nm, options$columns)
                            list(targets = i-1L, width = unname(map_named[[nm]]))
                          })
  )
  options
}

#' Column align (Bootstrap 5 classes)
#' @param options Options list.
#' @param cols Names or 1-based indices.
#' @param align "left","center","right".
#' @return Updated `options`.
#' @export
dt2_cols_align <- function(options = list(), cols, align = c("left","center","right")) {
  align <- match.arg(align)
  idx <- if (is.character(cols)) match(cols, options$columns) else as.integer(cols)
  cls <- switch(align, left="text-start", center="text-center", right="text-end")
  options$columnDefs <- c(options$columnDefs %||% list(),
                          lapply(idx, function(i) list(targets = i-1L, className = cls))
  )
  options
}

#' Hide columns
#' @param options Options list.
#' @param cols Names or 1-based indices.
#' @return Updated `options`.
#' @export
dt2_cols_hide <- function(options = list(), cols) {
  idx <- if (is.character(cols)) match(cols, options$columns) else as.integer(cols)
  options$columnDefs <- c(options$columnDefs %||% list(),
                          lapply(idx, function(i) list(targets = i-1L, visible = FALSE))
  )
  options
}

#' Escape/unescape columns content
#' @param options Options list.
#' @param cols Names or indices.
#' @param escape If FALSE, tells DT to trust HTML (use with care).
#' @return Updated `options`.
#' @export
dt2_cols_escape <- function(options = list(), cols, escape = TRUE) {
  idx <- if (is.character(cols)) match(cols, options$columns) else as.integer(cols)
  options$columnDefs <- c(options$columnDefs %||% list(),
                          lapply(idx, function(i) list(targets = i-1L, render = if (escape) htmlwidgets::JS("function(d,t){return d;}") else htmlwidgets::JS("function(d,t){return d;}")))
  )
  options
}

#' Bootstrap 5 table theme toggles
#' @param options Options list.
#' @param compact,striped,hover Toggles for table classes.
#' @return Updated `options`.
#' @export
dt2_theme <- function(options = list(), compact = TRUE, striped = TRUE, hover = TRUE) {
  options$dt2_theme <- list(compact = compact, striped = striped, hover = hover)
  options
}

#' Length menu helper
#' @param options Options list.
#' @param values Numeric vector of page lengths (e.g., c(10,25,50,-1)).
#' @param labels Character vector of labels.
#' @return Updated `options`.
#' @export
dt2_length_menu <- function(options = list(), values = c(10, 25, 50, -1),
                            labels = c("10", "25", "50", "All")) {
  options$lengthMenu <- list(values, labels)
  options
}
