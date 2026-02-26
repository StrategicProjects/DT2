# ---- Public API ---------------------------------------------------------------

#' Check for DataTables library updates
#'
#' Queries the npm registry to compare installed library versions against
#' the latest available versions. Version constraints are enforced to prevent
#' incompatible major version upgrades (e.g. jQuery 3.x will not jump to 4.x).
#'
#' @param quiet Logical. If \code{TRUE}, returns the result invisibly without
#'   printing. Default \code{FALSE}.
#' @return A data.frame (invisibly) with columns:
#'   \code{library}, \code{installed}, \code{latest}, \code{latest_ok},
#'   \code{constraint}, \code{status}.
#'
#'   Status values:
#'   \describe{
#'     \item{\code{"ok"}}{Library is up to date.}
#'     \item{\code{"UPDATE"}}{A compatible update is available.}
#'     \item{\code{"PINNED"}}{A new major version exists, but is blocked by
#'       the version constraint. The library is up to date within its
#'       allowed range.}
#'     \item{\code{"error"}}{Lookup failed (check your internet connection).}
#'   }
#' @export
#' @examples
#' \dontrun{
#' dt2_check_updates()
#'
#' # programmatic use
#' updates <- dt2_check_updates(quiet = TRUE)
#' updates[updates$status == "UPDATE", ]
#' }
dt2_check_updates <- function(quiet = FALSE) {

  libs        <- .dt2_lib_versions()
  npm_map     <- .dt2_npm_map()
  constraints <- .dt2_version_constraints()

  n         <- length(libs)
  latest    <- character(n)  # actual npm latest (may exceed constraint)
  latest_ok <- character(n)  # latest within constraint
  status    <- character(n)

  if (!quiet) message("Checking ", n, " libraries against npm registry...")

  for (i in seq_along(libs)) {
    nm  <- names(libs)[i]
    pkg <- npm_map[nm]
    pin <- constraints[nm]  # e.g. "3." or "0.2." or NA (no constraint)

    if (is.na(pkg)) {
      latest[i] <- latest_ok[i] <- NA_character_
      status[i] <- "error"
      next
    }

    # Fetch latest from npm
    ver <- .npm_latest_version(pkg)
    latest[i] <- ver

    if (is.na(ver)) {
      latest_ok[i] <- NA_character_
      status[i] <- "error"
      next
    }

    # No constraint or latest is within constraint
    if (is.na(pin) || startsWith(ver, pin)) {
      latest_ok[i] <- ver
      if (ver == libs[i]) {
        status[i] <- "ok"
      } else if (.version_gt(ver, libs[i])) {
        status[i] <- "UPDATE"
      } else {
        status[i] <- "ok"
      }
    } else {
      # Latest exceeds constraint — find best within range
      constrained <- .npm_latest_in_range(pkg, pin)
      latest_ok[i] <- constrained

      if (is.na(constrained) || constrained == libs[i]) {
        status[i] <- "PINNED"
      } else if (.version_gt(constrained, libs[i])) {
        status[i] <- "UPDATE"
      } else {
        status[i] <- "PINNED"
      }
    }
  }

  result <- data.frame(
    library    = names(libs),
    installed  = unname(libs),
    latest     = unname(latest),
    latest_ok  = unname(latest_ok),
    constraint = unname(ifelse(is.na(constraints[names(libs)]),
                               "", constraints[names(libs)])),
    status     = status,
    stringsAsFactors = FALSE
  )

  if (!quiet) .print_update_table(result)

  invisible(result)
}


#' Update DataTables JS/CSS libraries (developer tool)
#'
#' Checks for updates (respecting version constraints), patches version
#' numbers in the source files, and optionally runs
#' \code{tools/get-dt2-libs.sh} to download the new files.
#'
#' This function only works from the \strong{package source tree} (i.e.
#' during development). It will refuse to run from an installed package.
#'
#' @param pkg_dir Path to the DT2 source root (the directory containing
#'   \code{DESCRIPTION}). Defaults to the current working directory.
#' @param download Logical. If \code{TRUE}, runs the shell script after
#'   patching version numbers. Default \code{TRUE}.
#' @param dry_run Logical. If \code{TRUE}, shows what would change without
#'   modifying any files. Default \code{FALSE}.
#'
#' @details
#' The workflow is:
#' \enumerate{
#'   \item Query npm for the latest compatible version of every library.
#'   \item Patch \code{tools/get-dt2-libs.sh} (version variables).
#'   \item Patch \code{R/dt2_extensions.R} (extension registry).
#'   \item Patch \code{R/dt2_check_updates.R} (core lib versions).
#'   \item Patch \code{R/dt2_deps.R} (DataTables core version).
#'   \item Run \code{bash tools/get-dt2-libs.sh} to download the files.
#' }
#'
#' Version constraints prevent incompatible upgrades:
#' \itemize{
#'   \item jQuery is pinned to 3.x (DataTables 2 requires jQuery 3).
#'   \item pdfmake is pinned to 0.2.x (0.3.x has breaking changes and
#'     is not available on cdnjs).
#'   \item Bootstrap is pinned to 5.x.
#' }
#'
#' Libraries marked as \code{"PINNED"} are skipped. Only \code{"UPDATE"}
#' items are applied.
#'
#' @return Invisibly, a data.frame with the update results.
#' @export
#' @examples
#' \dontrun{
#' # from the DT2 source root:
#' dt2_update_libs()
#'
#' # preview changes without modifying anything:
#' dt2_update_libs(dry_run = TRUE)
#' }
dt2_update_libs <- function(pkg_dir = ".", download = TRUE, dry_run = FALSE) {

  pkg_dir <- normalizePath(pkg_dir, mustWork = FALSE)

  # ---- validate source tree ----
  script_path <- file.path(pkg_dir, "tools", "get-dt2-libs.sh")
  ext_path    <- file.path(pkg_dir, "R", "dt2_extensions.R")
  upd_path    <- file.path(pkg_dir, "R", "dt2_check_updates.R")
  deps_path   <- file.path(pkg_dir, "R", "dt2_deps.R")

  required <- c(
    DESCRIPTION             = file.path(pkg_dir, "DESCRIPTION"),
    `tools/get-dt2-libs.sh` = script_path,
    `R/dt2_extensions.R`    = ext_path
  )
  missing <- !file.exists(required)
  if (any(missing)) {
    stop("Not a DT2 source tree. Missing: ",
         paste(names(required)[missing], collapse = ", "),
         "\nRun this from the package root or set pkg_dir=.",
         call. = FALSE)
  }

  # ---- check for updates ----
  result  <- dt2_check_updates(quiet = FALSE)
  updates <- result[result$status == "UPDATE", , drop = FALSE]

  if (nrow(updates) == 0) {
    message("\nNothing to update!")
    return(invisible(result))
  }

  if (dry_run) {
    message("\n[DRY RUN] Would update ", nrow(updates), " library(ies):")
    for (i in seq_len(nrow(updates))) {
      message("  ", updates$library[i], ": ",
              updates$installed[i], " -> ", updates$latest_ok[i])
    }
    message("\n  Files that would be modified:")
    message("    - tools/get-dt2-libs.sh")
    message("    - R/dt2_extensions.R")
    message("    - R/dt2_check_updates.R")
    message("    - R/dt2_deps.R")
    return(invisible(result))
  }

  message("\nPatching ", nrow(updates), " version(s)...")

  # ---- shell script variable map ----
  shell_var_map <- .dt2_shell_var_map()

  # extension names in the registry
  ext_names <- c("Buttons", "ColReorder", "ColumnControl", "DateTime",
                 "FixedColumns", "FixedHeader", "KeyTable", "Responsive",
                 "RowGroup", "RowReorder", "Scroller", "SearchBuilder",
                 "SearchPanes", "Select", "StateRestore")

  # ---- patch each update ----
  for (i in seq_len(nrow(updates))) {
    lib     <- updates$library[i]
    old_ver <- updates$installed[i]
    new_ver <- updates$latest_ok[i]

    message("  ", lib, ": ", old_ver, " -> ", new_ver)

    # 1) Shell script
    var <- shell_var_map[lib]
    if (!is.na(var)) {
      .patch_file(script_path,
        paste0(var, '="', old_ver, '"'),
        paste0(var, '="', new_ver, '"')
      )
    }

    # 2) Extension registry (version + dir combo is unique per extension)
    if (lib %in% ext_names) {
      reg <- .dt2_extension_registry()
      ext_dir <- reg[[lib]]$dir
      .patch_file(ext_path,
        paste0('version = "', old_ver, '", dir = "', ext_dir, '"'),
        paste0('version = "', new_ver, '", dir = "', ext_dir, '"')
      )
    }

    # 3) Core versions in dt2_check_updates.R and dt2_deps.R
    if (lib == "DataTables") {
      .patch_file(upd_path,
        paste0('DataTables = "', old_ver, '"'),
        paste0('DataTables = "', new_ver, '"')
      )
      .patch_file(deps_path,
        paste0('dt_ver <- "', old_ver, '"'),
        paste0('dt_ver <- "', new_ver, '"')
      )
    } else if (lib %in% c("jQuery", "Moment", "JSZip", "PDFMake", "Bootstrap")) {
      .patch_file(upd_path,
        paste0(lib, ' = "', old_ver, '"'),
        paste0(lib, ' = "', new_ver, '"')
      )
    }
  }

  message("Done patching files.")

  # ---- download ----
  if (download) {
    message("\nRunning tools/get-dt2-libs.sh ...")
    old_wd <- setwd(pkg_dir)
    on.exit(setwd(old_wd), add = TRUE)
    rc <- system2("bash", "tools/get-dt2-libs.sh")
    if (rc != 0) {
      warning("Shell script exited with code ", rc, call. = FALSE)
    } else {
      message("\nLibraries downloaded successfully.")
    }
  } else {
    message("\nSkipping download. Run manually:")
    message("  cd ", pkg_dir)
    message("  bash tools/get-dt2-libs.sh")
  }

  invisible(result)
}


# ---- Version constraints -----------------------------------------------------

#' Version constraints for safe updates
#'
#' Defines the allowed version prefix for each library. Updates are only
#' applied within this prefix. For example, jQuery is constrained to
#' \code{"3."} so it will never auto-upgrade to 4.x.
#'
#' Rationale for each constraint:
#' \describe{
#'   \item{jQuery \code{"3."}}{DataTables 2.x requires jQuery 3.}
#'   \item{PDFMake \code{"0.2."}}{0.3.x has breaking changes and is not
#'     available on cdnjs.}
#'   \item{Bootstrap \code{"5."}}{DataTables BS5 styling requires Bootstrap 5.}
#'   \item{Moment \code{"2."}}{Major version pin for stability.}
#'   \item{JSZip \code{"3."}}{Major version pin for stability.}
#' }
#'
#' DataTables extensions do NOT have explicit constraints because their
#' major version tracks DataTables core compatibility (managed by the
#' DataTables project itself).
#'
#' @return Named character vector. Name = library name, value = version prefix.
#'   Only libraries with constraints are included (NA = no constraint).
#' @keywords internal
.dt2_version_constraints <- function() {
  c(
    jQuery    = "3.",
    PDFMake   = "0.2.",
    Bootstrap = "5.",
    Moment    = "2.",
    JSZip     = "3."
  )
}


# ---- npm helpers -------------------------------------------------------------

#' Mapping of DT2 library names to npm package names
#' @keywords internal
.dt2_npm_map <- function() {
  c(
    DataTables    = "datatables.net",
    jQuery        = "jquery",
    Moment        = "moment",
    JSZip         = "jszip",
    PDFMake       = "pdfmake",
    Bootstrap     = "bootstrap",
    Buttons       = "datatables.net-buttons",
    ColReorder    = "datatables.net-colreorder",
    ColumnControl = "datatables.net-columncontrol",
    DateTime      = "datatables.net-datetime",
    FixedColumns  = "datatables.net-fixedcolumns",
    FixedHeader   = "datatables.net-fixedheader",
    KeyTable      = "datatables.net-keytable",
    Responsive    = "datatables.net-responsive",
    RowGroup      = "datatables.net-rowgroup",
    RowReorder    = "datatables.net-rowreorder",
    Scroller      = "datatables.net-scroller",
    SearchBuilder = "datatables.net-searchbuilder",
    SearchPanes   = "datatables.net-searchpanes",
    Select        = "datatables.net-select",
    StateRestore  = "datatables.net-staterestore"
  )
}


#' Shell script variable names for each library
#' @keywords internal
.dt2_shell_var_map <- function() {
  c(
    DataTables    = "DT_VER",
    jQuery        = "JQUERY_VER",
    Moment        = "MOMENT_VER",
    JSZip         = "JSZIP_VER",
    PDFMake       = "PDFMAKE_VER",
    Bootstrap     = "BS_VER",
    Buttons       = "BTN_VER",
    ColReorder    = "CR_VER",
    ColumnControl = "CC_VER",
    DateTime      = "DTM_VER",
    FixedColumns  = "FC_VER",
    FixedHeader   = "FH_VER",
    KeyTable      = "KT_VER",
    Responsive    = "RS_VER",
    RowGroup      = "RG_VER",
    RowReorder    = "RR_VER",
    Scroller      = "SCR_VER",
    SearchBuilder = "SB_VER",
    SearchPanes   = "SP_VER",
    Select        = "SEL_VER",
    StateRestore  = "SR_VER"
  )
}


#' Get all current library versions in DT2
#'
#' Core library versions here must be kept in sync with
#' \code{R/dt2_deps.R} and \code{tools/get-dt2-libs.sh}.
#' Extension versions are read from the registry automatically.
#'
#' @return Named character vector
#' @keywords internal
.dt2_lib_versions <- function() {
  core <- c(
    DataTables = "2.3.4",
    jQuery     = "3.7.0",
    Moment     = "2.29.4",
    JSZip      = "3.10.1",
    PDFMake    = "0.2.7",
    Bootstrap  = "5.3.8"
  )

  reg <- .dt2_extension_registry()
  ext_vers <- vapply(reg, `[[`, "", "version")
  names(ext_vers) <- vapply(reg, `[[`, "", "name")

  c(core, ext_vers)
}


#' Fetch latest version of an npm package
#' @param pkg npm package name
#' @return version string or NA
#' @keywords internal
.npm_latest_version <- function(pkg) {
  url <- paste0("https://registry.npmjs.org/", pkg, "/latest")
  tryCatch({
    con <- url(url, open = "rb")
    on.exit(close(con), add = TRUE)
    raw <- readLines(con, warn = FALSE)
    json_text <- paste(raw, collapse = "")

    m <- regmatches(json_text, regexpr('"version"\\s*:\\s*"[^"]+"', json_text))
    if (length(m) == 0) return(NA_character_)
    ver <- sub('^"version"\\s*:\\s*"', "", m[1])
    sub('"$', "", ver)
  }, error = function(e) {
    NA_character_
  })
}


#' Fetch the latest version of an npm package within a version prefix
#'
#' Queries the full package metadata from npm and extracts all version
#' strings, then returns the highest version that starts with \code{prefix}.
#'
#' @param pkg npm package name
#' @param prefix version prefix, e.g. \code{"3."} or \code{"0.2."}
#' @return version string or NA
#' @keywords internal
.npm_latest_in_range <- function(pkg, prefix) {
  url <- paste0("https://registry.npmjs.org/", pkg)
  tryCatch({
    con <- url(url, open = "rb")
    on.exit(close(con), add = TRUE)
    raw <- readLines(con, warn = FALSE)
    json_text <- paste(raw, collapse = "")

    # Extract all version keys from "versions":{"x.y.z":{...},...}
    # We look for the "versions" object and extract its keys
    versions_block <- regmatches(json_text,
      regexpr('"versions"\\s*:\\s*\\{', json_text))
    if (length(versions_block) == 0) return(NA_character_)

    # Extract all quoted keys that look like versions (digits and dots)
    all_vers <- regmatches(json_text,
      gregexpr('"(\\d+\\.\\d+[^"]*)"\\s*:\\s*\\{', json_text))[[1]]
    all_vers <- sub('"\\s*:\\s*\\{$', "", all_vers)
    all_vers <- sub('^"', "", all_vers)

    # Filter: must start with prefix, no pre-release tags (alpha, beta, rc)
    matching <- all_vers[startsWith(all_vers, prefix)]
    matching <- matching[!grepl("[a-zA-Z]", matching)]  # exclude pre-release

    if (length(matching) == 0) return(NA_character_)

    # Find the highest version
    best <- matching[1]
    for (v in matching[-1]) {
      if (.version_gt(v, best)) best <- v
    }
    best
  }, error = function(e) {
    NA_character_
  })
}


# ---- version utilities -------------------------------------------------------

#' Compare two version strings (a > b?)
#' @keywords internal
.version_gt <- function(a, b) {
  va <- as.integer(strsplit(a, "[.-]")[[1]])
  vb <- as.integer(strsplit(b, "[.-]")[[1]])
  maxlen <- max(length(va), length(vb))
  va <- c(va, rep(0L, maxlen - length(va)))
  vb <- c(vb, rep(0L, maxlen - length(vb)))
  for (i in seq_len(maxlen)) {
    if (is.na(va[i]) || is.na(vb[i])) return(FALSE)
    if (va[i] > vb[i]) return(TRUE)
    if (va[i] < vb[i]) return(FALSE)
  }
  FALSE
}


# ---- file patching -----------------------------------------------------------

#' Replace a string in a file (first occurrence only)
#' @param path file path
#' @param old string to find (fixed, not regex)
#' @param new replacement string
#' @keywords internal
.patch_file <- function(path, old, new) {
  if (!file.exists(path)) return(invisible(NULL))
  txt  <- readLines(path, warn = FALSE)
  full <- paste(txt, collapse = "\n")
  if (!grepl(old, full, fixed = TRUE)) return(invisible(NULL))
  full <- sub(old, new, full, fixed = TRUE)
  writeLines(strsplit(full, "\n", fixed = TRUE)[[1]], path)
}


# ---- pretty printing ---------------------------------------------------------

#' Pretty-print the update check table
#' @keywords internal
.print_update_table <- function(result) {
  n_update <- sum(result$status == "UPDATE", na.rm = TRUE)
  n_pinned <- sum(result$status == "PINNED", na.rm = TRUE)
  n_error  <- sum(result$status == "error",  na.rm = TRUE)

  message("")
  message(sprintf("%-18s %-11s %-11s %-11s %s",
                  "Library", "Installed", "Latest", "Compat.", "Status"))
  message(strrep("-", 65))

  for (r in seq_len(nrow(result))) {
    st <- result$status[r]
    flag <- switch(st,
      "UPDATE" = "\U26A0\UFE0F  UPDATE",
      "ok"     = "\U2705 ok",
      "PINNED" = "\U0001F512 PINNED",
      "error"  = "\U274C error",
      st
    )
    # Show constraint info for pinned libs
    note <- ""
    if (st == "PINNED" && result$constraint[r] != "") {
      note <- paste0(" [pin: ", result$constraint[r], "x]")
    }

    message(sprintf("%-18s %-11s %-11s %-11s %s%s",
      result$library[r],
      result$installed[r],
      ifelse(is.na(result$latest[r]), "???", result$latest[r]),
      ifelse(is.na(result$latest_ok[r]), "???", result$latest_ok[r]),
      flag,
      note
    ))
  }

  message(strrep("-", 65))
  if (n_update > 0) {
    message(n_update, " compatible update(s) available.",
            " Use dt2_update_libs() to apply.")
  } else if (n_error == 0 && n_pinned == 0) {
    message("All libraries are up to date!")
  } else if (n_error == 0) {
    message("All libraries are up to date within their constraints.")
  }
  if (n_pinned > 0) {
    message(n_pinned, " library(ies) pinned to avoid breaking changes.",
            " Edit .dt2_version_constraints() to change.")
  }
  if (n_error > 0) {
    message(n_error, " lookup(s) failed (check your internet connection).")
  }
  message("")
}
