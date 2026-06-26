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
# \donttest{
dt2_check_updates()
#> Checking 21 libraries against npm registry...
#> 
#> Library            Installed   Latest      Compat.     Status
#> -----------------------------------------------------------------
#> DataTables         2.3.4       2.3.8       2.3.8       ⚠️  UPDATE
#> jQuery             3.7.0       4.0.0       3.7.1       ⚠️  UPDATE
#> Moment             2.29.4      2.30.1      2.30.1      ⚠️  UPDATE
#> JSZip              3.10.1      3.10.1      3.10.1      ✅ ok
#> PDFMake            0.2.7       0.3.11      0.2.23      ⚠️  UPDATE
#> Bootstrap          5.3.8       5.3.8       5.3.8       ✅ ok
#> Buttons            3.2.5       3.2.6       3.2.6       ⚠️  UPDATE
#> ColReorder         2.1.1       2.1.2       2.1.2       ⚠️  UPDATE
#> ColumnControl      1.1.0       1.2.1       1.2.1       ⚠️  UPDATE
#> DateTime           1.6.0       1.6.3       1.6.3       ⚠️  UPDATE
#> FixedColumns       5.0.5       5.0.5       5.0.5       ✅ ok
#> FixedHeader        4.0.3       4.0.6       4.0.6       ⚠️  UPDATE
#> KeyTable           2.12.1      2.12.2      2.12.2      ⚠️  UPDATE
#> Responsive         3.0.6       3.0.8       3.0.8       ⚠️  UPDATE
#> RowGroup           1.6.0       1.6.0       1.6.0       ✅ ok
#> RowReorder         1.5.0       1.5.1       1.5.1       ⚠️  UPDATE
#> Scroller           2.4.3       2.4.3       2.4.3       ✅ ok
#> SearchBuilder      1.8.4       1.8.4       1.8.4       ✅ ok
#> SearchPanes        2.3.5       2.3.5       2.3.5       ✅ ok
#> Select             3.1.0       3.1.3       3.1.3       ⚠️  UPDATE
#> StateRestore       1.4.2       1.4.3       1.4.3       ⚠️  UPDATE
#> -----------------------------------------------------------------
#> 14 compatible update(s) available. Use dt2_update_libs() to apply.
#> 

# programmatic use
updates <- dt2_check_updates(quiet = TRUE)
updates[updates$status == "UPDATE", ]
#>          library installed latest latest_ok constraint status
#> 1     DataTables     2.3.4  2.3.8     2.3.8            UPDATE
#> 2         jQuery     3.7.0  4.0.0     3.7.1         3. UPDATE
#> 3         Moment    2.29.4 2.30.1    2.30.1         2. UPDATE
#> 5        PDFMake     0.2.7 0.3.11    0.2.23       0.2. UPDATE
#> 7        Buttons     3.2.5  3.2.6     3.2.6            UPDATE
#> 8     ColReorder     2.1.1  2.1.2     2.1.2            UPDATE
#> 9  ColumnControl     1.1.0  1.2.1     1.2.1            UPDATE
#> 10      DateTime     1.6.0  1.6.3     1.6.3            UPDATE
#> 12   FixedHeader     4.0.3  4.0.6     4.0.6            UPDATE
#> 13      KeyTable    2.12.1 2.12.2    2.12.2            UPDATE
#> 14    Responsive     3.0.6  3.0.8     3.0.8            UPDATE
#> 16    RowReorder     1.5.0  1.5.1     1.5.1            UPDATE
#> 20        Select     3.1.0  3.1.3     3.1.3            UPDATE
#> 21  StateRestore     1.4.2  1.4.3     1.4.3            UPDATE
# }
```
