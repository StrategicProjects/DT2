#' Create a proxy for a DT2 table
#' @param id Widget id used in [dt2_output()].
#' @param session Shiny session.
#' @return A `"DT2Proxy"` object.
#' @export
dt2_proxy <- function(id, session = shiny::getDefaultReactiveDomain()) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required for dt2_proxy().", call. = FALSE)
  }
  structure(list(id = id, session = session), class = "DT2Proxy")
}

#' Replace all data in the table (proxy)
#' @param proxy [dt2_proxy()].
#' @param data New data.frame (will be serialized).
#' @export
dt2_replace_data <- function(proxy, data) {
  stopifnot(inherits(proxy, "DT2Proxy"))
  proxy$session$sendCustomMessage(paste0(proxy$id, "_proxy"),
                                  list(cmd = "replaceData", data = data))
  invisible(proxy)
}

#' Redraw the table (proxy)
#' @param proxy [dt2_proxy()].
#' @export
dt2_draw <- function(proxy) {
  stopifnot(inherits(proxy, "DT2Proxy"))
  proxy$session$sendCustomMessage(paste0(proxy$id, "_proxy"),
                                  list(cmd = "draw"))
  invisible(proxy)
}

#' Order the table (proxy)
#' @param proxy [dt2_proxy()].
#' @param ... Vectors `c(col, "asc"/"desc")`. If you pass `columns`, names will be resolved to indices.
#' @param columns Optional character vector of column names to resolve names to indices.
#' @export
dt2_proxy_order <- function(proxy, ..., columns = NULL) {
  stopifnot(inherits(proxy, "DT2Proxy"))
  ord <- lapply(list(...), function(x) {
    if (!is.null(columns) && is.character(x[[1]])) x[[1]] <- match(x[[1]], columns)
    x
  })
  proxy$session$sendCustomMessage(paste0(proxy$id, "_proxy"),
                                  list(cmd = "order", args = list(ord)))
  invisible(proxy)
}

#' Global search (proxy)
#' @param proxy A [dt2_proxy()] object.
#' @param value Search string.
#' @param regex Logical; treat `value` as a regular expression? Default: `FALSE`.
#' @param smart Logical; use DataTables smart search? Default: `TRUE`.
#' @param caseInsensitive Logical; case-insensitive search? Default: `TRUE`.
#' @return The proxy, invisibly.
#' @export
dt2_proxy_search <- function(proxy, value, regex = FALSE, smart = TRUE, caseInsensitive = TRUE) {
  stopifnot(inherits(proxy, "DT2Proxy"))
  proxy$session$sendCustomMessage(paste0(proxy$id, "_proxy"),
                                  list(cmd = "search", args = list(value, regex, smart, caseInsensitive)))
  invisible(proxy)
}

#' Page navigation (proxy)
#' @param proxy A [dt2_proxy()] object.
#' @param page Navigation action: `"first"`, `"previous"`, `"next"`, `"last"`,
#'   or `"number"` (go to a specific page).
#' @param number Page number (1-based). Only used when `page = "number"`.
#' @return The proxy, invisibly.
#' @export
dt2_proxy_page <- function(proxy, page = c("first","previous","next","last","number"), number = NULL) {
  stopifnot(inherits(proxy, "DT2Proxy"))
  page <- match.arg(page)
  proxy$session$sendCustomMessage(paste0(proxy$id, "_proxy"),
                                  list(cmd = "page", args = list(page, number)))
  invisible(proxy)
}

#' Select rows (proxy; Select extension)
#' @param proxy [dt2_proxy()].
#' @param indexes 1-based row indices.
#' @param reset If TRUE, clear selection before selecting.
#' @export
dt2_select_rows <- function(proxy, indexes, reset = TRUE) {
  stopifnot(inherits(proxy, "DT2Proxy"))
  proxy$session$sendCustomMessage(paste0(proxy$id, "_proxy"),
                                  list(cmd = "selectRows", args = list(as.integer(indexes), isTRUE(reset))))
  invisible(proxy)
}
