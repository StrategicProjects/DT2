#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

# logging helpers (english logs)
.dt2_info  <- function(..., .envir = parent.frame()) cli::cli_inform(c("i" = ...), .envir = .envir)
.dt2_warn  <- function(..., .envir = parent.frame()) cli::cli_warn(c("!" = ...), .envir = .envir)
.dt2_abort <- function(..., .envir = parent.frame()) cli::cli_abort(c("x" = ...), .envir = .envir)

# resolve columns by names/indices (and optionally tidyselect if you pass data)
#' @keywords internal
.dt2_resolve_cols <- function(data, options, cols) {
  if (is.null(cols)) return(integer())
  if (is.numeric(cols)) return(as.integer(cols))
  if (is.character(cols)) return(match(cols, options$columns))
  # optional tidyselect path (only if data is provided)
  if (!is.null(data) && requireNamespace("tidyselect", quietly = TRUE)) {
    nm <- names(data)
    idx <- tidyselect::eval_select(rlang::enquo(cols), setNames(seq_along(nm), nm))
    return(as.integer(idx))
  }
  .dt2_abort("Invalid columns specification. Use names, indices, or provide data for tidyselect.")
}

# internal env to hold named renderers
.dt2_renderers <- new.env(parent = emptyenv())

#' Register a named JS renderer
#'
#' @param name Unique name (character scalar).
#' @param js A \code{htmlwidgets::JS()} function or a JSON helper expression.
#'
#' @return Invisibly, the name.
#' @export
dt2_register_renderer <- function(name, js) {
  stopifnot(is.character(name), length(name) == 1)
  if (!inherits(js, "JS_EVAL")) {
    stop("`js` must be created with htmlwidgets::JS(...).", call. = FALSE)
  }
  assign(name, js, envir = .dt2_renderers)
  invisible(name)
}

#' Use a named JS renderer on columns
#'
#' @param options Options list (returned modified).
#' @param col_specs Column names or indices.
#' @param name Name used in \code{dt2_register_renderer()}.
#'
#' @return Modified \code{options}.
#' @export
dt2_use_renderer <- function(options = list(), col_specs, name) {
  #`%||%` <- function(a, b) if (is.null(a)) b else a
  if (is.character(col_specs)) col_specs <- match(col_specs, options$columns)
  js <- get0(name, envir = .dt2_renderers, inherits = FALSE)
  if (is.null(js)) stop(sprintf("Renderer '%s' is not registered.", name), call. = FALSE)

  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}
