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
#> DataTables         2.3.4       3.0.4       3.0.4       ⚠️  UPDATE
#> jQuery             3.7.0       4.0.0       3.7.1       ⚠️  UPDATE
#> Moment             2.29.4      ^22.22.2 || ^24.15.0 || >=26.0.0 2.31.0      ⚠️  UPDATE
#> JSZip              3.10.1      3.10.2      3.10.2      ⚠️  UPDATE
#> PDFMake            0.2.7       0.3.11      0.2.23      ⚠️  UPDATE
#> Bootstrap          5.3.8       5.3.8       5.3.8       ✅ ok
#> Buttons            3.2.5       4.0.3       4.0.3       ⚠️  UPDATE
#> ColReorder         2.1.1       3.0.2       3.0.2       ⚠️  UPDATE
#> ColumnControl      1.1.0       2.0.2       2.0.2       ⚠️  UPDATE
#> DateTime           1.6.0       2.0.0       2.0.0       ⚠️  UPDATE
#> FixedColumns       5.0.5       6.0.0       6.0.0       ⚠️  UPDATE
#> FixedHeader        4.0.3       5.0.0       5.0.0       ⚠️  UPDATE
#> KeyTable           2.12.1      3.0.0       3.0.0       ⚠️  UPDATE
#> Responsive         3.0.6       4.0.3       4.0.3       ⚠️  UPDATE
#> RowGroup           1.6.0       2.0.0       2.0.0       ⚠️  UPDATE
#> RowReorder         1.5.0       2.0.0       2.0.0       ⚠️  UPDATE
#> Scroller           2.4.3       3.0.0       3.0.0       ⚠️  UPDATE
#> SearchBuilder      1.8.4       2.0.1       2.0.1       ⚠️  UPDATE
#> SearchPanes        2.3.5       2.3.5       2.3.5       ✅ ok
#> Select             3.1.0       4.0.1       4.0.1       ⚠️  UPDATE
#> StateRestore       1.4.2       2.0.1       2.0.1       ⚠️  UPDATE
#> -----------------------------------------------------------------
#> 19 compatible update(s) available. Use dt2_update_libs() to apply.
#> 

# programmatic use
updates <- dt2_check_updates(quiet = TRUE)
updates[updates$status == "UPDATE", ]
#>          library installed                           latest latest_ok
#> 1     DataTables     2.3.4                            3.0.4     3.0.4
#> 2         jQuery     3.7.0                            4.0.0     3.7.1
#> 3         Moment    2.29.4 ^22.22.2 || ^24.15.0 || >=26.0.0    2.31.0
#> 4          JSZip    3.10.1                           3.10.2    3.10.2
#> 5        PDFMake     0.2.7                           0.3.11    0.2.23
#> 7        Buttons     3.2.5                            4.0.3     4.0.3
#> 8     ColReorder     2.1.1                            3.0.2     3.0.2
#> 9  ColumnControl     1.1.0                            2.0.2     2.0.2
#> 10      DateTime     1.6.0                            2.0.0     2.0.0
#> 11  FixedColumns     5.0.5                            6.0.0     6.0.0
#> 12   FixedHeader     4.0.3                            5.0.0     5.0.0
#> 13      KeyTable    2.12.1                            3.0.0     3.0.0
#> 14    Responsive     3.0.6                            4.0.3     4.0.3
#> 15      RowGroup     1.6.0                            2.0.0     2.0.0
#> 16    RowReorder     1.5.0                            2.0.0     2.0.0
#> 17      Scroller     2.4.3                            3.0.0     3.0.0
#> 18 SearchBuilder     1.8.4                            2.0.1     2.0.1
#> 20        Select     3.1.0                            4.0.1     4.0.1
#> 21  StateRestore     1.4.2                            2.0.1     2.0.1
#>    constraint status
#> 1             UPDATE
#> 2          3. UPDATE
#> 3          2. UPDATE
#> 4          3. UPDATE
#> 5        0.2. UPDATE
#> 7             UPDATE
#> 8             UPDATE
#> 9             UPDATE
#> 10            UPDATE
#> 11            UPDATE
#> 12            UPDATE
#> 13            UPDATE
#> 14            UPDATE
#> 15            UPDATE
#> 16            UPDATE
#> 17            UPDATE
#> 18            UPDATE
#> 20            UPDATE
#> 21            UPDATE
# }
```
