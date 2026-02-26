#' Build htmlwidgets dependencies for DT2
#'
#' Constructs the dependency list dynamically based on the requested extensions.
#' Only loads CSS/JS for selected extensions, keeping the page lightweight.
#'
#' All version numbers are read from [.dt2_lib_versions()] (defined in
#' `dt2_check_updates.R`) so there is a single source of truth for versions.
#'
#' @param bs `"bootstrap5"` (default) or `"core"` styling mode.
#' @param include_bs Logical; if TRUE and `bs="bootstrap5"`, include Bootstrap assets.
#'   Default TRUE. Set FALSE only if your host page already provides Bootstrap.
#' @param extensions Character vector of extension names (e.g., `c("Buttons", "Select")`).
#'   Use `dt2_extensions()` to see all available extensions.
#' @return List of `htmlDependency()` objects in correct load order.
#' @keywords internal
#' @importFrom htmltools htmlDependency
dt2_deps <- function(bs = c("bootstrap5", "core"),
                     include_bs = TRUE,
                     extensions = character()) {
  bs <- match.arg(bs)
  bs <- .dt2_lock_mode(bs)

  # Single source of truth for versions
  vers <- .dt2_lib_versions()

  pkg_path <- function(...) {
    p <- system.file(..., package = "DT2")
    if (!nzchar(p)) stop("DT2: resource not found: ", file.path(...), call. = FALSE)
    p
  }

  dep <- function(name, version, src_dir, script = NULL, stylesheet = NULL) {
    htmltools::htmlDependency(
      name = name, version = version, src = c(file = src_dir),
      script = script, stylesheet = stylesheet
    )
  }

  deps <- list()

  # ------------------------------------------------------------------
  # 0) Bootstrap (if bs5 mode and include_bs)
  # ------------------------------------------------------------------
  if (bs == "bootstrap5" && isTRUE(include_bs)) {
    bs_ver <- vers[["Bootstrap"]]
    deps <- append(deps, list(
      dep("bootstrap", bs_ver,
          pkg_path("htmlwidgets", "lib", "bootstrap", bs_ver),
          script = "js/bootstrap.bundle.min.js",
          stylesheet = "css/bootstrap.min.css")
    ))
  }

  # ------------------------------------------------------------------
  # 1) DataTables core CSS
  # ------------------------------------------------------------------
  dt_ver <- vers[["DataTables"]]
  if (bs == "core") {
    deps <- append(deps, list(
      dep("datatables-core-css", dt_ver,
          pkg_path("htmlwidgets", "lib", "datatables", dt_ver),
          stylesheet = "css/dataTables.dataTables.min.css")
    ))
  } else {
    deps <- append(deps, list(
      dep("datatables-bs5-css", dt_ver,
          pkg_path("htmlwidgets", "lib", "datatables", dt_ver),
          stylesheet = "css/dataTables.bootstrap5.min.css")
    ))
  }

  # ------------------------------------------------------------------
  # 2) Extension CSS (only for requested extensions)
  # ------------------------------------------------------------------
  reg <- .dt2_extension_registry()
  ext_names <- .dt2_resolve_extensions(extensions)

  for (ext_name in ext_names) {
    ext <- reg[[ext_name]]
    css_files <- if (bs == "core") ext$css_core else ext$css_bs5
    if (length(css_files) > 0) {
      css_files <- if (is.character(css_files)) css_files else unlist(css_files)
      deps <- append(deps, list(
        dep(paste0("dt-", tolower(ext_name), "-css"), ext$version,
            pkg_path("htmlwidgets", "lib", ext$dir, ext$version),
            stylesheet = css_files)
      ))
    }
  }

  # ------------------------------------------------------------------
  # 3) Common JS libraries (jQuery, moment)
  # ------------------------------------------------------------------
  jq_ver <- vers[["jQuery"]]
  mo_ver <- vers[["Moment"]]

  deps <- append(deps, list(
    dep("jquery", jq_ver,
        pkg_path("htmlwidgets", "lib", "jquery", jq_ver),
        script = "jquery.min.js"),
    dep("moment", mo_ver,
        pkg_path("htmlwidgets", "lib", "moment", mo_ver),
        script = "moment.min.js")
  ))

  # jszip and pdfmake only if Buttons is loaded
  if ("Buttons" %in% ext_names) {
    jz_ver <- vers[["JSZip"]]
    pm_ver <- vers[["PDFMake"]]
    deps <- append(deps, list(
      dep("jszip", jz_ver,
          pkg_path("htmlwidgets", "lib", "jszip", jz_ver),
          script = "jszip.min.js"),
      dep("pdfmake", pm_ver,
          pkg_path("htmlwidgets", "lib", "pdfmake", pm_ver),
          script = c("pdfmake.min.js", "vfs_fonts.js"))
    ))
  }

  # ------------------------------------------------------------------
  # 4) DataTables core JS
  # ------------------------------------------------------------------
  if (bs == "core") {
    deps <- append(deps, list(
      dep("datatables-core-js", dt_ver,
          pkg_path("htmlwidgets", "lib", "datatables", dt_ver),
          script = "js/dataTables.min.js")
    ))
  } else {
    deps <- append(deps, list(
      dep("datatables-core-js", dt_ver,
          pkg_path("htmlwidgets", "lib", "datatables", dt_ver),
          script = c("js/dataTables.min.js", "js/dataTables.bootstrap5.min.js"))
    ))
  }

  # ------------------------------------------------------------------
  # 5) Extension JS (in dependency order)
  # ------------------------------------------------------------------
  for (ext_name in ext_names) {
    ext <- reg[[ext_name]]
    js_files <- if (bs == "core") ext$js_core else ext$js_bs5
    if (length(js_files) > 0) {
      js_files <- if (is.character(js_files)) js_files else unlist(js_files)
      deps <- append(deps, list(
        dep(paste0("dt-", tolower(ext_name), "-js"), ext$version,
            pkg_path("htmlwidgets", "lib", ext$dir, ext$version),
            script = js_files)
      ))
    }
  }

  # ------------------------------------------------------------------
  # 6) DT2 CSS fixes (always last)
  # ------------------------------------------------------------------
  deps <- append(deps, list(
    dep("dt2-fixes", "1.0.0",
        pkg_path("htmlwidgets"),
        stylesheet = "dt2-fixes.css")
  ))

  deps
}
