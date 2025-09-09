# R/deps.R

# Default extension versions (only those NOT fixed in dt2.yaml)
.dt2_ext_versions <- list(
  autofill      = "2.7.0",
  colreorder    = "2.1.1",
  fixedcolumns  = "5.0.4",
  fixedheader   = "4.0.3",
  keytable      = "2.12.1",
  #responsive    = "3.0.6",   # opcional
  rowgroup      = "1.5.2",
  rowreorder    = "1.5.0",
  searchbuilder = "1.8.3",
  staterestore  = "1.4.1"
)

# Local file map for these extensions
.dt2_ext_files <- list(
  autofill = list(
    js  = c("js/dataTables.autoFill.min.js", "js/autoFill.bootstrap5.min.js"),
    css = "css/autoFill.bootstrap5.min.css"
  ),
  colreorder = list(
    js  = c("js/dataTables.colReorder.min.js", "js/colReorder.bootstrap5.min.js"),
    css = "css/colReorder.bootstrap5.min.css"
  ),
  fixedcolumns = list(
    js  = c("js/dataTables.fixedColumns.min.js", "js/fixedColumns.bootstrap5.min.js"),
    css = "css/fixedColumns.bootstrap5.min.css"
  ),
  fixedheader = list(
    js  = c("js/dataTables.fixedHeader.min.js", "js/fixedHeader.bootstrap5.min.js"),
    css = "css/fixedHeader.bootstrap5.min.css"
  ),
  keytable = list(
    js  = c("js/dataTables.keyTable.min.js", "js/keyTable.bootstrap5.min.js"),
    css = "css/keyTable.bootstrap5.min.css"
  ),
  rowgroup = list(
    js  = c("js/dataTables.rowGroup.min.js", "js/rowGroup.bootstrap5.min.js"),
    css = "css/rowGroup.bootstrap5.min.css"
  ),
  rowreorder = list(
    js  = c("js/dataTables.rowReorder.min.js", "js/rowReorder.bootstrap5.min.js"),
    css = "css/rowReorder.bootstrap5.min.css"
  ),
  searchbuilder = list(
    js  = c("js/dataTables.searchBuilder.min.js", "js/searchBuilder.bootstrap5.min.js"),
    css = "css/searchBuilder.bootstrap5.min.css"
  ),
  staterestore = list(
    js  = c("js/dataTables.stateRestore.min.js", "js/stateRestore.bootstrap5.min.js"),
    css = "css/stateRestore.bootstrap5.min.css"
  )
)

# Utility to create an htmlDependency
.dt2_dep_ext <- function(ext, ver, base_dir) {
  files <- .dt2_ext_files[[ext]]
  if (is.null(files)) return(NULL)

  htmltools::htmlDependency(
    name       = sprintf("datatables-%s-bs5-%s", ext, ver),
    version    = ver,
    src        = c(file = file.path(base_dir, ext, ver)),
    script     = files$js,
    stylesheet = files$css
  )
}

#' Build extension dependencies not already included in dt2.yaml
#'
#' @param extensions Character vector of extension names.
#' @return List of htmlDependency objects.
#' @keywords internal
dt2_dependency_extensions <- function(extensions = NULL) {
  if (is.null(extensions) || !length(extensions)) return(list())
  exts <- tolower(unique(extensions))

  # Already included in dt2.yaml, skip them here
  skip <- c("jquery", "datatables-core", "buttons", "scroller",
            "searchpanes", "select", "moment", "jszip", "pdfmake",
            "responsive", "columncontrol")

  exts <- setdiff(exts, skip)

  base_dir <- system.file("htmlwidgets/lib", package = "DT2")
  vers     <- .dt2_ext_versions

  deps <- list()
  for (ext in exts) {
    ver <- vers[[ext]]
    if (is.null(ver)) next
    dep <- .dt2_dep_ext(ext, ver, base_dir)
    if (!is.null(dep)) deps[[length(deps) + 1]] <- dep
  }
  deps
}
