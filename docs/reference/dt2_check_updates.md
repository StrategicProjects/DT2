# Check for DataTables library updates

Queries the npm registry to compare installed library versions against
the latest available versions. Version constraints are enforced to
prevent incompatible major version upgrades (e.g. jQuery 3.x will not
jump to 4.x).

## Usage

``` r
dt2_check_updates(quiet = FALSE)
```

## Arguments

- quiet:

  Logical. If `TRUE`, returns the result invisibly without printing.
  Default `FALSE`.

## Value

A data.frame (invisibly) with columns: `library`, `installed`, `latest`,
`latest_ok`, `constraint`, `status`.

Status values:

- `"ok"`:

  Library is up to date.

- `"UPDATE"`:

  A compatible update is available.

- `"PINNED"`:

  A new major version exists, but is blocked by the version constraint.
  The library is up to date within its allowed range.

- `"error"`:

  Lookup failed (check your internet connection).

## Examples

``` r
if (FALSE) { # \dontrun{
dt2_check_updates()

# programmatic use
updates <- dt2_check_updates(quiet = TRUE)
updates[updates$status == "UPDATE", ]
} # }
```
