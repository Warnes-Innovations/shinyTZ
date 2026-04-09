# CRAN Submission Comments

## Test environments

- Ubuntu 22.04 (GitHub Actions), R-devel
- Ubuntu 22.04 (GitHub Actions), R-release  
- Ubuntu 22.04 (GitHub Actions), R-oldrel-1
- macOS (GitHub Actions), R-release
- Windows (GitHub Actions), R-release

## R CMD check results

```
── R CMD check results ─────────────────── shinyTZ 0.2.0 ────
Duration: Xm Ys

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

## Notes on CRAN policies

- This package does not submit data to external services; the JavaScript only
  reads browser-local information (timezone, locale) and sends it to the local
  R Shiny server session via `Shiny.setInputValue()`.

- The JavaScript file in `inst/www/shinytz.js` is required for the core
  functionality. It uses only standard browser APIs (`Intl.DateTimeFormat`,
  `navigator.language`, `Date.getTimezoneOffset`) with no external requests.

- All examples that require a running Shiny session are wrapped in `\dontrun{}`.

- All tests that require a running browser are marked `skip_on_cran()`.

## Resubmission notes

(Update this section with any notes on previous submissions and how they were
addressed.)
