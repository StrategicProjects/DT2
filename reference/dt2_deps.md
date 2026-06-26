# Build htmlwidgets dependencies for DT2

Constructs the dependency list dynamically based on the requested
extensions. Only loads CSS/JS for selected extensions, keeping the page
lightweight.

## Usage

``` r
dt2_deps(
  bs = c("bootstrap5", "core"),
  include_bs = TRUE,
  extensions = character()
)
```

## Arguments

- bs:

  `"bootstrap5"` (default) or `"core"` styling mode.

- include_bs:

  Logical; if TRUE and `bs="bootstrap5"`, include Bootstrap assets.
  Default TRUE. Set FALSE only if your host page already provides
  Bootstrap.

- extensions:

  Character vector of extension names (e.g., `c("Buttons", "Select")`).
  Use
  [`dt2_extensions()`](https://strategicprojects.github.io/DT2/reference/dt2_extensions.md)
  to see all available extensions.

## Value

List of `htmlDependency()` objects in correct load order.

## Details

All version numbers are read from
[`.dt2_lib_versions()`](https://strategicprojects.github.io/DT2/reference/dot-dt2_lib_versions.md)
(defined in `dt2_check_updates.R`) so there is a single source of truth
for versions.
