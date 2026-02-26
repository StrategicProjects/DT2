# Update DataTables JS/CSS libraries (developer tool)

Checks for updates (respecting version constraints), patches version
numbers in the source files, and optionally runs `tools/get-dt2-libs.sh`
to download the new files.

## Usage

``` r
dt2_update_libs(pkg_dir = ".", download = TRUE, dry_run = FALSE)
```

## Arguments

- pkg_dir:

  Path to the DT2 source root (the directory containing `DESCRIPTION`).
  Defaults to the current working directory.

- download:

  Logical. If `TRUE`, runs the shell script after patching version
  numbers. Default `TRUE`.

- dry_run:

  Logical. If `TRUE`, shows what would change without modifying any
  files. Default `FALSE`.

## Value

Invisibly, a data.frame with the update results.

## Details

This function only works from the **package source tree** (i.e. during
development). It will refuse to run from an installed package.

The workflow is:

1.  Query npm for the latest compatible version of every library.

2.  Patch `tools/get-dt2-libs.sh` (version variables).

3.  Patch `R/dt2_extensions.R` (extension registry).

4.  Patch `R/dt2_check_updates.R` (core lib versions).

5.  Patch `R/dt2_deps.R` (DataTables core version).

6.  Run `bash tools/get-dt2-libs.sh` to download the files.

Version constraints prevent incompatible upgrades:

- jQuery is pinned to 3.x (DataTables 2 requires jQuery 3).

- pdfmake is pinned to 0.2.x (0.3.x has breaking changes and is not
  available on cdnjs).

- Bootstrap is pinned to 5.x.

Libraries marked as `"PINNED"` are skipped. Only `"UPDATE"` items are
applied.

## Examples

``` r
if (FALSE) { # \dontrun{
# from the DT2 source root:
dt2_update_libs()

# preview changes without modifying anything:
dt2_update_libs(dry_run = TRUE)
} # }
```
