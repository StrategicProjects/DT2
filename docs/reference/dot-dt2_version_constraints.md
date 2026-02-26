# Version constraints for safe updates

Defines the allowed version prefix for each library. Updates are only
applied within this prefix. For example, jQuery is constrained to `"3."`
so it will never auto-upgrade to 4.x.

## Usage

``` r
.dt2_version_constraints()
```

## Value

Named character vector. Name = library name, value = version prefix.
Only libraries with constraints are included (NA = no constraint).

## Details

Rationale for each constraint:

- jQuery `"3."`:

  DataTables 2.x requires jQuery 3.

- PDFMake `"0.2."`:

  0.3.x has breaking changes and is not available on cdnjs.

- Bootstrap `"5."`:

  DataTables BS5 styling requires Bootstrap 5.

- Moment `"2."`:

  Major version pin for stability.

- JSZip `"3."`:

  Major version pin for stability.

DataTables extensions do NOT have explicit constraints because their
major version tracks DataTables core compatibility (managed by the
DataTables project itself).
