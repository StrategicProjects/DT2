# zzz.R — DT2 internal state
.DT2_STATE <- new.env(parent = emptyenv())

#' Lock Bootstrap mode per document (prevents mixing core/bootstrap5)
#' @keywords internal
.dt2_lock_mode <- function(bs) {
  if (!exists("bs_mode", envir = .DT2_STATE, inherits = FALSE)) {
    .DT2_STATE$bs_mode <- bs
  } else if (!identical(.DT2_STATE$bs_mode, bs)) {
    warning(sprintf(
      "DT2: this document already locked bs=\"%s\"; ignoring request for bs=\"%s\".",
      .DT2_STATE$bs_mode, bs
    ), call. = FALSE)
    bs <- .DT2_STATE$bs_mode
  }
  bs
}

.onLoad <- function(libname, pkgname) {
  # Reset state on package load
  if (exists("bs_mode", envir = .DT2_STATE, inherits = FALSE)) {
    rm("bs_mode", envir = .DT2_STATE)
  }
}
