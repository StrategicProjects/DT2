# Fetch the latest version of an npm package within a version prefix

Queries the full package metadata from npm and extracts all version
strings, then returns the highest version that starts with `prefix`.

## Usage

``` r
.npm_latest_in_range(pkg, prefix)
```

## Arguments

- pkg:

  npm package name

- prefix:

  version prefix, e.g. `"3."` or `"0.2."`

## Value

version string or NA
