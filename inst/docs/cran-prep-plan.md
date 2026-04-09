# shinyTZ CRAN Preparation Plan

**Version:** 0.2.0  
**Author:** Dr. Greg Warnes  
**Date:** 2026-04-09  
**Branch:** `copilot/prepare-shinytz-for-cran-submission`

---

## Executive Summary

This document tracks all work required to bring shinyTZ from its current development state (v0.1.2) to a CRAN-ready package. It records decisions made, issues encountered, and completion status for every task.

---

## Current State Assessment

### ✅ Already in Place
- Core functionality: `renderDatetime()`, `renderDate()`, `renderTime()`, `datetimeOutput()`, `dateOutput()`, `timeOutput()`, `useShinyTZ()`, `get_browser_tz()`, `format_in_tz()`
- Basic roxygen2 documentation on all exported functions
- Initial test suite (8 files, ~80 test cases)
- Design document (`inst/docs/design-document.md`)
- Demo app (`inst/examples/demo-app/app.R`)
- JavaScript timezone detection (`inst/www/shinytz.js`)

### ❌ Critical Bugs (Must Fix Before CRAN)

| # | Issue | File(s) | Severity |
|---|-------|---------|----------|
| 1 | `%||%` operator used but not defined or imported | `R/renderDatetime.R`, `R/renderDate.R`, `R/renderTime.R` | CRITICAL |
| 2 | Duplicate function definitions for all three Output functions | `R/datetime-outputs.R` + `R/dateOutput.R`, `R/datetimeOutput.R`, `R/timeOutput.R` | CRITICAL |
| 3 | NAMESPACE missing all `importFrom` statements | `NAMESPACE` | CRITICAL |
| 4 | `.onLoad()` missing from `zzz.R` (resource path not auto-registered) | `R/zzz.R` | HIGH |

### ❌ DESCRIPTION / Package Metadata Issues

| # | Issue | Severity |
|---|-------|----------|
| 5 | `URL` and `BugReports` point to wrong repo (`gwarnes-mdsol` → `Warnes-Innovations`) | HIGH |
| 6 | License inconsistency: DESCRIPTION says `GPL-2`, README says `MIT`, LICENSE file is GPL-2 text | HIGH |
| 7 | `LazyData: true` with no data files → CRAN NOTE | MEDIUM |
| 8 | `DBI` and `dplyr` in `Suggests` but not used in tests or vignettes | LOW |
| 9 | Missing `Config/testthat/edition` field | LOW |

### ❌ Documentation / CRAN Requirements

| # | Issue | Severity |
|---|-------|----------|
| 10 | No vignettes | HIGH |
| 11 | README Quick Start omits required `useShinyTZ()` call | HIGH |
| 12 | NEWS.md missing entries for v0.1.1 and v0.1.2 | MEDIUM |
| 13 | `renderDate()` lacks `formatter` parameter (inconsistent with renderDatetime) | MEDIUM |
| 14 | `renderTime()` lacks `locale` parameter (inconsistent with renderDatetime/renderDate) | LOW |
| 15 | Package-level help file (`zzz.R`) does not link to key functions | LOW |
| 16 | Missing `cran-comments.md` | MEDIUM |

### ❌ CI/CD (Completely Missing)

| # | Issue | Severity |
|---|-------|----------|
| 17 | No GitHub Actions R-CMD-check workflow | HIGH |
| 18 | No test coverage workflow (covr) | MEDIUM |
| 19 | No pkgdown documentation site workflow | MEDIUM |
| 20 | No `copilot-setup-steps.yml` (Copilot cloud agent setup) | LOW |

### ❌ Testing Gaps

| # | Issue | Severity |
|---|-------|----------|
| 21 | No `testServer()` tests for actual render execution | HIGH |
| 22 | No `shinytest2` UI/UX integration tests | MEDIUM |
| 23 | No test for `useShinyTZ()` function | MEDIUM |
| 24 | No snapshot tests for output HTML structure | LOW |

---

## Implementation Checklist

### Phase 1: Critical Bug Fixes
- [x] Define `%||%` operator in `R/utils.R` with proper `@importFrom` or base R fallback
- [x] Remove duplicate Output function definitions (keep individual files, remove from `datetime-outputs.R`)
- [x] Add `@importFrom` roxygen tags to all R files + regenerate NAMESPACE
- [x] Add `.onLoad()` to `zzz.R` to auto-register `inst/www` resource path

### Phase 2: DESCRIPTION / Package Metadata
- [x] Fix `URL` and `BugReports` to correct repo
- [x] Resolve license inconsistency (keep GPL-2 throughout)
- [x] Remove `LazyData: true`
- [x] Remove unused `DBI` and `dplyr` from `Suggests`
- [x] Add `Config/testthat/edition: 3`
- [x] Bump version to `0.2.0`

### Phase 3: API Consistency
- [x] Add `formatter` parameter to `renderDate()`
- [x] Add `locale` parameter to `renderTime()`

### Phase 4: Documentation
- [x] Fix README: add `useShinyTZ()` to Quick Start, fix license badge, add status badges
- [x] Update NEWS.md: add v0.1.1, v0.1.2, v0.2.0 entries
- [x] Create `vignettes/getting-started.Rmd`
- [x] Create `vignettes/advanced-usage.Rmd`
- [x] Update package-level help file (`zzz.R` or `shinyTZ-package.R`)
- [x] Add `cran-comments.md`

### Phase 5: CI/CD
- [x] Add `.github/workflows/R-CMD-check.yaml`
- [x] Add `.github/workflows/test-coverage.yaml`
- [x] Add `.github/workflows/pkgdown.yaml`
- [x] Add `.github/copilot-setup-steps.yml`
- [x] Update `.Rbuildignore` for new files

### Phase 6: Testing Enhancements
- [x] Add `testServer()` tests for actual render execution
- [x] Add tests for `useShinyTZ()` function
- [x] Improve `test-integration.R` with more realistic session mocks
- [x] Add snapshot tests for UI output HTML

---

## Design Decisions Made

### DD-1: `%||%` Implementation Strategy
**Decision:** Define `%||%` as an internal utility function in `R/utils.R` rather than importing from `rlang`.  
**Rationale:** Avoids adding a heavyweight dependency; `%||%` is trivial to define. R 4.4.0+ exports it from base, but since we target R ≥ 4.1.0, we define it ourselves. Marked `@noRd` to keep it internal.

### DD-2: Duplicate Output Definitions
**Decision:** Remove the three individual Output .R files (`dateOutput.R`, `datetimeOutput.R`, `timeOutput.R`) and keep the consolidated `datetime-outputs.R`.  
**Rationale:** The individual files are exact duplicates of functions in `datetime-outputs.R`. Keeping `datetime-outputs.R` is more maintainable. The consolidated file already contains all three functions with identical signatures.

### DD-3: License
**Decision:** Keep GPL-2 (as stated in DESCRIPTION and LICENSE file). Update README to correctly reflect GPL-2.  
**Rationale:** The GPL-2 text was the original license intent (it appears in the LICENSE file). The README saying "MIT" was an error.

### DD-4: `renderDate()` API Consistency
**Decision:** Add `formatter` parameter to `renderDate()` for consistency with `renderDatetime()`.  
**Rationale:** Both functions operate on datetime objects and should have the same level of flexibility. Users should not need to know which function supports custom formatters.

### DD-5: `renderTime()` API Consistency
**Decision:** Add `locale` parameter to `renderTime()` for consistency with `renderDatetime()` and `renderDate()`.  
**Rationale:** Locale is a reserved parameter for future use across all three render functions. It should be present for API consistency.

### DD-6: `.onLoad()` Auto-Registration
**Decision:** Add `.onLoad()` to register `inst/www` resource path automatically. Keep the manual registration in `useShinyTZ()` as a belt-and-suspenders safeguard.  
**Rationale:** Users who include `useShinyTZ()` in their UI should not need to worry about resource registration order. Auto-registration in `.onLoad()` handles edge cases (e.g., `devtools::load_all()` scenarios).

---

## Questions Encountered

### Q-1: `useShinyTZ()` vs. Auto-loading JavaScript
**Question:** Should `useShinyTZ()` be required, or should the JavaScript auto-load via `.onLoad()`?  
**Status:** ✅ Resolved — Keep `useShinyTZ()` as the explicit opt-in mechanism. This aligns with `shinyjs::useShinyjs()` and other Shiny extension packages. It gives users control over script placement in the `<head>`. Auto-registration of the resource path in `.onLoad()` handles the server side.

### Q-2: shinytest2 Dependency
**Question:** Should `shinytest2` be added to Suggests for UI testing?  
**Status:** ✅ Resolved — Add `shinytest2` to Suggests for optional UI testing. Since shinytest2 requires a headless browser (Chromium), CI tests using shinytest2 should be guarded with `skip_on_cran()`. Mark any such tests with `skip_if_not_installed("shinytest2")`.

### Q-3: Minimum R Version
**Question:** Should R ≥ 4.1.0 be maintained, or bump to 4.2.0+?  
**Status:** ✅ Resolved — Keep R ≥ 4.1.0 to maximize compatibility. The `%||%` operator is available in R ≥ 4.4.0 from base, but we define it ourselves to maintain backward compatibility.

### Q-4: DBI/dplyr in Suggests
**Question:** Should DBI and dplyr remain in Suggests?  
**Status:** ✅ Resolved — Remove them for now. They were anticipated for vignette examples but the vignettes will demonstrate database usage conceptually without requiring live DB connections. If a database vignette is added later, they can be restored.

---

## CRAN Submission Checklist

Before submitting to CRAN, verify all of the following:

- [ ] `R CMD check --as-cran` passes with 0 ERRORs, 0 WARNINGs, 0 NOTEs
- [ ] All examples run without errors (or are wrapped in `\dontrun{}`)
- [ ] All exported functions have complete documentation
- [ ] Package installed cleanly from `.tar.gz`
- [ ] `devtools::spell_check()` returns no unexpected words
- [ ] `devtools::check_win_devel()` passes
- [ ] Test coverage ≥ 80% via `covr::package_coverage()`
- [ ] `cran-comments.md` updated with check results
- [ ] NEWS.md up to date
- [ ] Version bumped appropriately

---

## File Changes Summary

| File | Action | Reason |
|------|--------|--------|
| `R/utils.R` | CREATE | Define `%||%` operator |
| `R/dateOutput.R` | DELETE | Duplicate of `datetime-outputs.R` |
| `R/datetimeOutput.R` | DELETE | Duplicate of `datetime-outputs.R` |
| `R/timeOutput.R` | DELETE | Duplicate of `datetime-outputs.R` |
| `R/zzz.R` | MODIFY | Add `.onLoad()` for resource path registration |
| `R/renderDate.R` | MODIFY | Add `formatter` parameter |
| `R/renderTime.R` | MODIFY | Add `locale` parameter |
| `R/renderDatetime.R` | MODIFY | Add `@importFrom` tags |
| `R/format_in_tz.R` | MODIFY | Add `@importFrom` tags |
| `R/get_browser_tz.R` | MODIFY | Add `@importFrom` tags |
| `DESCRIPTION` | MODIFY | Fix URL/BugReports, License, LazyData, Suggests, version |
| `NAMESPACE` | REGENERATE | Add all importFrom statements |
| `README.md` | MODIFY | Fix license, add useShinyTZ() to quickstart, add badges |
| `NEWS.md` | MODIFY | Add v0.1.1, v0.1.2, v0.2.0 entries |
| `cran-comments.md` | CREATE | CRAN submission notes |
| `vignettes/getting-started.Rmd` | CREATE | Intro vignette |
| `vignettes/advanced-usage.Rmd` | CREATE | Advanced vignette |
| `.github/workflows/R-CMD-check.yaml` | CREATE | CI R CMD check |
| `.github/workflows/test-coverage.yaml` | CREATE | CI test coverage |
| `.github/workflows/pkgdown.yaml` | CREATE | CI docs site |
| `.github/copilot-setup-steps.yml` | CREATE | Copilot cloud agent setup |
| `.Rbuildignore` | MODIFY | Add new files to ignore list |
| `tests/testthat/test-render-server.R` | CREATE | testServer() tests |
| `tests/testthat/test-useShinyTZ.R` | CREATE | useShinyTZ() tests |
| `tests/testthat/test-utils.R` | CREATE | %||% operator tests |
