# Null-coalescing operator (available in base R >= 4.4; provided here for R >= 4.1)
#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

# logging helpers (english logs)
.dt2_info  <- function(..., .envir = parent.frame()) cli::cli_inform(c("i" = ...), .envir = .envir)
.dt2_warn  <- function(..., .envir = parent.frame()) cli::cli_warn(c("!" = ...), .envir = .envir)
.dt2_abort <- function(..., .envir = parent.frame()) cli::cli_abort(c("x" = ...), .envir = .envir)

# Resolve column names OR 1-based indices to 1-based integer indices.
# Unlike a bare match(), this warns loudly instead of silently returning NA
# when `options$columns` is unset or a name does not exist, so the common
# "forgot to set options$columns" footgun is visible rather than silent.
#' @keywords internal
.dt2_name_to_idx <- function(cols, options) {
  if (is.numeric(cols)) return(as.integer(cols))
  if (!is.character(cols)) {
    .dt2_abort("Columns must be column names (character) or 1-based indices (numeric).")
  }
  if (is.null(options$columns)) {
    .dt2_warn(paste(
      "Column names were passed but {.code options$columns} is unset, so they",
      "cannot be resolved. Set {.code options$columns <- names(data)} before the",
      "column helpers, or pass 1-based indices instead."
    ))
    return(rep(NA_integer_, length(cols)))
  }
  idx <- match(cols, options$columns)
  if (anyNA(idx)) {
    .dt2_warn("Unknown column name{?s}: {.val {cols[is.na(idx)]}}.")
  }
  idx
}

# Render an R scalar as a safe JS string literal (properly quoted and escaped)
# for interpolation into generated JS, instead of sprintf("'%s'", x) which
# breaks when `x` contains a quote. `NULL` becomes `null_as` (e.g. "null"/"undefined").
#' @keywords internal
.dt2_js_str <- function(x, null_as = "null") {
  if (is.null(x)) return(null_as)
  as.character(jsonlite::toJSON(x, auto_unbox = TRUE))
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
  col_specs <- .dt2_name_to_idx(col_specs, options)
  js <- get0(name, envir = .dt2_renderers, inherits = FALSE)
  if (is.null(js)) stop(sprintf("Renderer '%s' is not registered.", name), call. = FALSE)

  cds <- lapply(col_specs, function(i) list(targets = i - 1L, render = js))
  options$columnDefs <- c(options$columnDefs %||% list(), cds)
  options
}
