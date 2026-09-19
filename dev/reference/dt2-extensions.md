# DT2 Extension Registry

Declarative registry of all DataTables extensions supported by DT2. Each
extension specifies its version, JS/CSS files for core mode, and
optional bridge files for Bootstrap 5 mode.

Users select extensions via
`dt2(extensions = c("Buttons", "Responsive"))`. Only the selected
extensions (plus required dependencies) are loaded.

## Usage

``` r
.dt2_extension_registry()
```
