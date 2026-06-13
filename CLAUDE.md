# CLAUDE.md

Guidance for working in the **DT2** repository.

## What this package is

DT2 is an `htmlwidgets` binding for **DataTables v2** (the JS library by SpryMedia).
It configures DataTables via plain R lists (1:1 with the JS API), with modular
extension loading, Bootstrap 5 styling, and Shiny integration (proxy, events,
inline inputs, server-side processing). Written from scratch for the v2 API —
not a fork of the `DT` package.

- R code: `R/`  ·  JS runtime: `inst/htmlwidgets/dt2.js`  ·  bundled libs: `inst/htmlwidgets/lib/`
- Vignettes: `vignettes/`  ·  built site: `docs/` (gitignored, see below)

## Common commands

```r
# load for interactive dev / run a quick check
pkgload::load_all(".")

# regenerate Rd from roxygen (package uses roxygen2 8 — Config/roxygen2/version)
roxygen2::roxygenise()

# tests (testthat edition 3)
testthat::test_dir("tests/testthat")

# full check (clean: 0/0/0)
devtools::check(args = "--as-cran")

# CRAN pre-submission (results emailed to maintainer)
devtools::check_win_devel(); devtools::check_win_release()
```

## Conventions / gotchas

- **roxygen2 8**: version is recorded in `Config/roxygen2/version` (no `RoxygenNote`).
  Run `roxygenise()` after changing any `#'` block. Build with the system R
  (`Rscript`/`R CMD`), which is R 4.6 here.
- **`options$columns` is the name→index map.** Name-based helpers
  (`dt2_cols_*`, `dt2_format_*`, `dt2_order`, ...) resolve names against
  `options$columns`. The user must set `opts <- list(columns = names(df))`
  *before* calling them; `dt2()` injects it from the data, but that runs after
  the helpers. Resolution is centralized in `.dt2_name_to_idx()` (`R/dt2_utils.R`),
  which **warns** on unresolved names instead of returning silent `NA`.
- **Generated JS must be quote-safe.** Use `.dt2_js_str()` (jsonlite) to build
  JS string literals, never `sprintf("'%s'", x)`.
- **SSP query strings:** `dt2.js` encodes query-string *keys* with
  `encodeURIComponent`, so the server parser (`.dt2_parse_ssp_request`) must
  URL-decode keys, not just values.
- **CRAN is live:** DT2 is on CRAN. Public API is frozen — do not remove
  exported functions; cross-link/deprecate instead.

## pkgdown site (`docs/`)

- The site theme uses **`tidytemplate`** (NOT on CRAN). Install before building:
  `pak::pak("tidyverse/tidytemplate")`.
- `docs/` is in `.gitignore` but the tracked site is **force-committed**. To
  rebuild and commit:
  1. `R CMD INSTALL .` then `pkgdown::build_site(install = FALSE)`
  2. delete orphaned versioned asset dirs (old `dt2-binding-*`, old `bootstrap-*`)
  3. `git add -f docs/`, then unstage every `.DS_Store`
- `_pkgdown.yml` has a curated grouped `reference:` index — keep it in sync with
  `NAMESPACE` exports (every export must appear exactly once or pkgdown errors).

## Release flow (followed for 0.1.2)

Bump `DESCRIPTION` Version+Date → update `NEWS.md` → update `cran-comments.md`
→ `check(--as-cran)` + win-builder devel/release → rebuild site → publish GitHub
release/tag `vX.Y.Z` (`gh release ...`) → `devtools::submit_cran()` (maintainer
runs this; CRAN confirmation is emailed).

## House rules in this repo

- Never stage `.DS_Store` or `.Rhistory` (they show as modified but are noise).
- Branch per change + PR + merge; reference issues with `Closes #N`.
