## Resubmission

This is a resubmission of 0.1.2. The previous submission was flagged by the
incoming pre-test with one NOTE on r-devel-windows: the `dt2()` examples ran
in > 10s elapsed. I have wrapped all but one minimal `dt2()` example in
`\donttest{}` (in `dt2()` and `dt2_theme()`), so the timed example run is now
well under the threshold. No code was changed.

## Update

This is a minor update (0.1.2) of a package already on CRAN. It fixes two
bugs and improves robustness; see NEWS.md for the full list. The most
user-visible changes are:

* `dt2_cols_escape()` now escapes HTML when `escape = TRUE` (previously the
  argument had no effect).
* The default server-side processing handler now applies global search and
  column ordering (query-string keys were not being URL-decoded).

There are no reverse dependencies on CRAN.

## Test environments

* local macOS, R 4.6.0
* GitHub Actions: ubuntu-latest (r-devel, r-release, r-oldrel-1),
  macOS-latest (r-release), windows-latest (r-release)

## R CMD check results

0 errors | 0 warnings | 0 notes

The package bundles the 'DataTables' JavaScript library and its extensions,
so the installed size may be reported as a NOTE on some CRAN check machines
(unchanged from 0.1.1).
