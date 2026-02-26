#' @title DT2 Extension Registry
#' @description
#' Declarative registry of all DataTables extensions supported by DT2.
#' Each extension specifies its version, JS/CSS files for core mode,
#' and optional bridge files for Bootstrap 5 mode.
#'
#' Users select extensions via `dt2(extensions = c("Buttons", "Responsive"))`.
#' Only the selected extensions (plus required dependencies) are loaded.
#' @keywords internal
#' @name dt2-extensions

# Extension registry — one entry per extension
# Fields:
#   name      : canonical name (used in `extensions` arg)
#   version   : current version string
#   dir       : directory under inst/htmlwidgets/lib/
#   js_core   : JS files for core mode
#   js_bs5    : additional JS files for bootstrap5 mode (appended after js_core)
#   css_core  : CSS files for core mode
#   css_bs5   : CSS files for bootstrap5 mode (replaces css_core)
#   requires  : character vector of other extension names that must be loaded first
#   optional  : is this extension only loaded when explicitly requested? (default TRUE)

.dt2_extension_registry <- function() {
  list(
    Buttons = list(
      name = "Buttons", version = "3.2.5", dir = "buttons",
      js_core = c("js/dataTables.buttons.min.js",
                   "js/buttons.colVis.min.js",
                   "js/buttons.html5.min.js",
                   "js/buttons.print.min.js"),
      js_bs5  = c("js/dataTables.buttons.min.js",
                   "js/buttons.bootstrap5.min.js",
                   "js/buttons.colVis.min.js",
                   "js/buttons.html5.min.js",
                   "js/buttons.print.min.js"),
      css_core = "css/buttons.dataTables.min.css",
      css_bs5  = "css/buttons.bootstrap5.min.css",
      requires = character()
    ),

    ColReorder = list(
      name = "ColReorder", version = "2.1.1", dir = "colreorder",
      js_core  = "js/dataTables.colReorder.min.js",
      js_bs5   = "js/dataTables.colReorder.min.js",
      css_core = "css/colReorder.dataTables.min.css",
      css_bs5  = "css/colReorder.bootstrap5.min.css",
      requires = character()
    ),

    ColumnControl = list(
      name = "ColumnControl", version = "1.1.0", dir = "columncontrol",
      js_core  = "js/dataTables.columnControl.min.js",
      js_bs5   = c("js/dataTables.columnControl.min.js",
                    "js/columnControl.bootstrap5.min.js"),
      css_core = "css/columnControl.dataTables.min.css",
      css_bs5  = "css/columnControl.bootstrap5.min.css",
      requires = character()
    ),

    DateTime = list(
      name = "DateTime", version = "1.6.0", dir = "datetime",
      js_core  = "js/dataTables.dateTime.min.js",
      js_bs5   = "js/dataTables.dateTime.min.js",
      css_core = "css/dataTables.dateTime.min.css",
      css_bs5  = "css/dataTables.dateTime.min.css",
      requires = character()
    ),

    FixedColumns = list(
      name = "FixedColumns", version = "5.0.5", dir = "fixedcolumns",
      js_core  = "js/dataTables.fixedColumns.min.js",
      js_bs5   = "js/dataTables.fixedColumns.min.js",
      css_core = "css/fixedColumns.dataTables.min.css",
      css_bs5  = "css/fixedColumns.bootstrap5.min.css",
      requires = character()
    ),

    FixedHeader = list(
      name = "FixedHeader", version = "4.0.3", dir = "fixedheader",
      js_core  = "js/dataTables.fixedHeader.min.js",
      js_bs5   = "js/dataTables.fixedHeader.min.js",
      css_core = "css/fixedHeader.dataTables.min.css",
      css_bs5  = "css/fixedHeader.bootstrap5.min.css",
      requires = character()
    ),

    KeyTable = list(
      name = "KeyTable", version = "2.12.1", dir = "keytable",
      js_core  = "js/dataTables.keyTable.min.js",
      js_bs5   = "js/dataTables.keyTable.min.js",
      css_core = "css/keyTable.dataTables.min.css",
      css_bs5  = "css/keyTable.bootstrap5.min.css",
      requires = character()
    ),

    Responsive = list(
      name = "Responsive", version = "3.0.6", dir = "responsive",
      js_core  = "js/dataTables.responsive.min.js",
      js_bs5   = c("js/dataTables.responsive.min.js",
                    "js/responsive.bootstrap5.js"),
      css_core = "css/responsive.dataTables.min.css",
      css_bs5  = "css/responsive.bootstrap5.min.css",
      requires = character()
    ),

    RowGroup = list(
      name = "RowGroup", version = "1.6.0", dir = "rowgroup",
      js_core  = "js/dataTables.rowGroup.min.js",
      js_bs5   = "js/dataTables.rowGroup.min.js",
      css_core = "css/rowGroup.dataTables.min.css",
      css_bs5  = "css/rowGroup.bootstrap5.min.css",
      requires = character()
    ),

    RowReorder = list(
      name = "RowReorder", version = "1.5.0", dir = "rowreorder",
      js_core  = "js/dataTables.rowReorder.min.js",
      js_bs5   = "js/dataTables.rowReorder.min.js",
      css_core = "css/rowReorder.dataTables.min.css",
      css_bs5  = "css/rowReorder.bootstrap5.min.css",
      requires = character()
    ),

    Scroller = list(
      name = "Scroller", version = "2.4.3", dir = "scroller",
      js_core  = "js/dataTables.scroller.min.js",
      js_bs5   = "js/dataTables.scroller.min.js",
      css_core = "css/scroller.dataTables.min.css",
      css_bs5  = "css/scroller.bootstrap5.min.css",
      requires = character()
    ),

    SearchBuilder = list(
      name = "SearchBuilder", version = "1.8.4", dir = "searchbuilder",
      js_core  = "js/dataTables.searchBuilder.min.js",
      js_bs5   = c("js/dataTables.searchBuilder.min.js",
                    "js/searchBuilder.bootstrap5.min.js"),
      css_core = "css/searchBuilder.dataTables.min.css",
      css_bs5  = "css/searchBuilder.bootstrap5.min.css",
      requires = c("DateTime")
    ),

    SearchPanes = list(
      name = "SearchPanes", version = "2.3.5", dir = "searchpanes",
      js_core  = "js/dataTables.searchPanes.min.js",
      js_bs5   = c("js/dataTables.searchPanes.min.js",
                    "js/searchPanes.bootstrap5.min.js"),
      css_core = "css/searchPanes.dataTables.min.css",
      css_bs5  = "css/searchPanes.bootstrap5.min.css",
      requires = character()
    ),

    Select = list(
      name = "Select", version = "3.1.0", dir = "select",
      js_core  = "js/dataTables.select.min.js",
      js_bs5   = "js/dataTables.select.min.js",
      css_core = "css/select.dataTables.min.css",
      css_bs5  = "css/select.bootstrap5.min.css",
      requires = character()
    ),

    StateRestore = list(
      name = "StateRestore", version = "1.4.2", dir = "staterestore",
      js_core  = "js/dataTables.stateRestore.min.js",
      js_bs5   = c("js/dataTables.stateRestore.min.js",
                    "js/stateRestore.bootstrap5.min.js"),
      css_core = "css/stateRestore.dataTables.min.css",
      css_bs5  = "css/stateRestore.bootstrap5.min.css",
      requires = character()
    )
  )
}

#' List available DataTables extensions
#'
#' @return A data.frame with columns `name`, `version`, `dir`.
#' @export
#' @examples
#' dt2_extensions()
dt2_extensions <- function() {
  reg <- .dt2_extension_registry()
  data.frame(
    name    = vapply(reg, `[[`, "", "name"),
    version = vapply(reg, `[[`, "", "version"),
    dir     = vapply(reg, `[[`, "", "dir"),
    stringsAsFactors = FALSE
  )
}

#' Resolve extension names with dependency ordering
#' @param extensions character vector of extension names
#' @return ordered character vector (dependencies first)
#' @keywords internal
.dt2_resolve_extensions <- function(extensions) {
  reg <- .dt2_extension_registry()
  valid <- names(reg)

  # Normalize names (case-insensitive matching)
  resolved <- vapply(extensions, function(ext) {
    idx <- match(tolower(ext), tolower(valid))
    if (is.na(idx)) {
      cli::cli_warn("DT2: unknown extension {.val {ext}}. Available: {.val {valid}}")
      return(NA_character_)
    }
    valid[idx]
  }, character(1), USE.NAMES = FALSE)
  resolved <- resolved[!is.na(resolved)]

  # Add required dependencies
  all_needed <- resolved
  repeat {
    new_deps <- character()
    for (ext in all_needed) {
      reqs <- reg[[ext]]$requires
      new_deps <- c(new_deps, setdiff(reqs, all_needed))
    }
    if (length(new_deps) == 0) break
    all_needed <- c(new_deps, all_needed)
  }

  unique(all_needed)
}

#' Auto-detect extensions from options
#'
#' Scans the options list for keys that imply certain extensions.
#' For example, `buttons` implies Buttons, `select` implies Select, etc.
#'
#' @param options DataTables options list
#' @return character vector of detected extension names
#' @keywords internal
.dt2_detect_extensions <- function(options) {
  detected <- character()

  # Buttons: options$buttons OR buttons anywhere inside layout OR dom contains B
  if (!is.null(options$buttons)) {
    detected <- c(detected, "Buttons")
  }
  # Deep-scan layout for button references (handles nested lists)
  if (!is.null(options$layout)) {
    layout_str <- paste(deparse(options$layout), collapse = " ")
    if (grepl("button", layout_str, ignore.case = TRUE)) {
      detected <- c(detected, "Buttons")
    }
    # Check layout for searchBuilder, searchPanes references
    if (grepl("searchBuilder", layout_str, ignore.case = FALSE)) {
      detected <- c(detected, "SearchBuilder")
    }
    if (grepl("searchPanes", layout_str, ignore.case = FALSE)) {
      detected <- c(detected, "SearchPanes")
    }
  }
  # Legacy dom string: B = Buttons
  if (!is.null(options$dom) && grepl("B", options$dom, fixed = TRUE)) {
    detected <- c(detected, "Buttons")
  }

  # Select
  if (!is.null(options$select) && !identical(options$select, FALSE)) {
    detected <- c(detected, "Select")
  }

  # Responsive
  if (isTRUE(options$responsive)) {
    detected <- c(detected, "Responsive")
  }

  # ColumnControl
  if (!is.null(options$columnControl)) {
    detected <- c(detected, "ColumnControl")
  }

  # SearchBuilder
  if (!is.null(options$searchBuilder)) {
    detected <- c(detected, "SearchBuilder")
  }

  # SearchPanes
  if (!is.null(options$searchPanes)) {
    detected <- c(detected, "SearchPanes")
  }

  # FixedHeader
  if (!is.null(options$fixedHeader) && !identical(options$fixedHeader, FALSE)) {
    detected <- c(detected, "FixedHeader")
  }

  # FixedColumns
  if (!is.null(options$fixedColumns)) {
    detected <- c(detected, "FixedColumns")
  }

  # Scroller
  if (isTRUE(options$scroller) || is.list(options$scroller)) {
    detected <- c(detected, "Scroller")
  }

  # RowGroup
  if (!is.null(options$rowGroup)) {
    detected <- c(detected, "RowGroup")
  }

  # RowReorder
  if (!is.null(options$rowReorder)) {
    detected <- c(detected, "RowReorder")
  }

  # ColReorder
  if (!is.null(options$colReorder)) {
    detected <- c(detected, "ColReorder")
  }

  # KeyTable
  if (!is.null(options$keys) && !identical(options$keys, FALSE)) {
    detected <- c(detected, "KeyTable")
  }

  unique(detected)
}
