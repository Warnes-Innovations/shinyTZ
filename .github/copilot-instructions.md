# GitHub Copilot Instructions for shinyTZ

# 🛑🛑🛑 STOP - MANDATORY PRE-FLIGHT - READ THIS BEFORE RESPONDING 🛑🛑🛑

☐ State which user and project copilot-instructions.md sections apply to this request
☐ Check if any Agent Skills apply (list them explicitly)
☐ If multi-step work: Create todo list with #manage_todo_list
☐ Mark tasks in-progress and completed as you work
☐ Use #code-review before finalizing ANY code changes
☐ Use "we" collaborative language and refer to user as "Dr. Greg"
☐ Monitor and report token usage at checkpoints (700K/850K/950K)

**If you cannot check ALL boxes above, STOP and ask for clarification.**

**Example Response Format:**
```
**Following copilot-instructions.md sections: Shiny Patterns, R Package Development**
**Applicable Agent Skills: #code-review, #r-package-patterns**
**Will use #manage_todo_list for multi-step tracking**

Dr. Greg, we need to...
```

---

# 📖 REQUIRED READING

**ALWAYS read the user-level copilot-instructions.md file first:**
- **Location**: `/home/warnes/src/vscode-config/copilot-instructions.md`
- **Contains**: Communication style, token monitoring, cross-project development patterns
- **Why**: Establishes baseline behavior and standards across all projects

**THEN review the design document:**
- **Location**: `inst/docs/design-document.md`
- **Contains**: Architecture, design decisions, API specifications, implementation details, usage examples
- **When to consult**: Before implementing features, when understanding design rationale, for API specifications
- **Why**: Design document provides the complete technical specification and architectural decisions

**This file (project-specific) provides:**
- Quick reference for critical anti-patterns and gotchas
- Workflow requirements and checklists
- Development practices specific to shinyTZ
- Links to Agent Skills for procedural guidance

---

## Quick Skill Reference

**Workflow & Quality:**
- **#code-review** - REQUIRED before finalizing any code changes
- **#git-commit-message** - For commit message generation  
- **#manage_todo_list** - For multi-step task tracking and planning

**Development:**
- **#r-package-patterns** - R package structure, documentation, testing
- **#shiny-ui-patterns** - Shiny UI updates without flickering
- **#javascript-integration** - JavaScript/R integration for timezone detection

---

## Project Purpose

**shinyTZ** provides timezone-aware date and time rendering for R Shiny applications.

**Core Goal:** Make displaying dates and times in Shiny "just work" - automatically handling each user's timezone and locale settings without requiring manual configuration.

**Design Philosophy:**
- **Zero Configuration**: Works out-of-the-box without setup
- **Transparent**: Drop-in replacements for existing Shiny outputs
- **User-Centric**: Automatically adapts to each user's browser timezone
- **Fallback Safe**: Degrades gracefully if JavaScript unavailable

**Problem Solved:**
```r
# ❌ BEFORE shinyTZ - Shows server timezone to all users
output$timestamp <- renderText({
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")  # Confusing for remote users!
})

# ✅ WITH shinyTZ - Automatically shows user's local timezone
output$timestamp <- renderDatetime({
  Sys.time()  # Just works!
})
```

---

## ⚠️ CRITICAL WORKFLOW CHECKLIST

**Before implementing ANY code changes, verify you will:**

1. ✅ **Create/update unit tests** - Code changes and tests must be implemented together
2. ✅ **Follow anti-patterns** - Check relevant sections below before coding
3. ✅ **Review changes** - Use systematic code review before finalizing
4. ✅ **Update documentation** - Regenerate docs if modifying exported functions

**After making changes, verify you have:**

1. ✅ **Tests passing** - All new/modified code has passing tests
2. ✅ **Documentation updated** - roxygen2 comments and .Rd files current
3. ✅ **No anti-patterns** - Reviewed against project-specific warnings
4. ✅ **User informed** - Confirmed completion to user

---

## Critical Anti-Patterns

**See design document (`inst/docs/design-document.md`) for detailed implementation examples.**

### NEVER: renderUI() for Content Updates

**Why:** UI flickering, lost scroll position, memory overhead, poor performance.

**Pattern:** Use static UI structure with reactive content updates.

**See:** #shiny-ui-patterns skill for complete guidance.

### NEVER: Early String Conversion

**Why:** Loses timezone information permanently.

**Pattern:** Keep POSIXct/POSIXlt objects until final rendering step.

**Key Rule:** Datetime objects remain as POSIXct/POSIXlt through all reactive logic. Only convert to strings in render functions.

---

## JavaScript Integration Requirements

**See design document and #javascript-integration skill for implementation details.**

### ALWAYS: Graceful Degradation

**Critical:** All JavaScript functionality MUST have R fallbacks.

**Pattern:**
1. Detect timezone via `Intl.DateTimeFormat()` on `shiny:connected`
2. Store as reactive input (`input$shinytz_browser_tz`)
3. Fallback to `Sys.timezone()` if NULL/invalid
4. Validate all browser-provided values before use

### ALWAYS: Validate Browser Data

**Critical:** Never trust browser-provided timezones without validation.

**Pattern:**
- Check against `OlsonNames()` in R
- Log warnings (not errors) for invalid timezones
- Use server timezone as fallback
- Never crash on invalid input

---

## R Package Development Standards

**See #r-package-patterns skill and design document for complete guidance.**

### Documentation Requirements

**Every exported function MUST have:**
1. Complete roxygen2 documentation
2. Title, description, all parameters documented
3. `@export` tag
4. Executable examples (use `\dontrun{}` for Shiny apps)
5. `@return` describing what function returns

**See design document for full roxygen2 example.**

### Testing Requirements

**Every exported function MUST have:**
1. Unit tests covering normal operation
2. Edge case tests (NULL, NA, invalid input)
3. Timezone conversion validation
4. Graceful degradation tests

**Test coverage goals:**
- Exported functions: 100%
- Internal functions: >80%

**See design document for test examples.**

### Package Structure

**Core files:**
- `R/datetime-renders.R` - renderDatetime(), renderDate(), renderTime()
- `R/datetime-outputs.R` - datetimeOutput(), dateOutput(), timeOutput()
- `R/timezone-utils.R` - get_browser_tz(), format_in_tz()
- `inst/www/shinytz.js` - Browser timezone detection

**See design document for complete package structure.**

### Package Version and Date Management

**See #user-r-workflow skill for complete guidance on:**
- Updating DESCRIPTION version and date before reinstalling
- Versioning rules (Patch/Minor/Major)
- Reinstalling after code changes with `devtools::document()` and `renv::install(".")`
- When to update version and why to regenerate documentation first

---

## Common Gotchas

1. **JavaScript timing** - Timezone detection happens after page load; always check for NULL
2. **Timezone validation** - Not all browser-reported timezones are in OlsonNames()
3. **POSIXct attributes** - Timezone stored in `attr(x, "tzone")`, can be lost in operations
4. **Format string escaping** - Use `\%` in roxygen2 examples (not `%`)
5. **Shiny resource paths** - Must call `addResourcePath()` before using inst/www files
6. **Reactive context** - `get_browser_tz()` requires active Shiny session
7. **lubridate dependency** - Always use `lubridate::with_tz()` for timezone conversion
8. **JavaScript encoding** - Use `jsonlite::toJSON()` for safe R-to-JS data passing

---

## Architecture Overview

### Core Components

**Render Functions** (`R/renderDatetime.R`, `R/renderDate.R`, `R/renderTime.R`):
- Use `shiny::createRenderFunction()` pattern for Shiny integration
- Accept POSIXct/POSIXlt objects, validate with `shiny::validate()` and `shiny::need()`
- Support custom `formatter` function parameter (takes precedence over `format` string)
- All functions follow same parameter pattern: `expr`, `format`, `formatter`, `tz`, `locale`, `show_tz`

**Output Functions** (`R/datetime-outputs.R`):
- UI-side components: `datetimeOutput()`, `dateOutput()`, `timeOutput()`
- Simple wrappers around `shiny::textOutput()` with custom CSS classes
- Enable client-side styling and future enhancements

**Timezone Utilities** (`R/get_browser_tz.R`, `R/format_in_tz.R`):
- `get_browser_tz()` reads `input$shinytz_browser_tz` reactive value
- `format_in_tz()` wraps `lubridate::with_tz()` + `format()` for consistent conversion
- Both functions handle NULL/invalid inputs gracefully with fallbacks

**JavaScript Detection** (`inst/www/shinytz.js`):
- Runs on `shiny:connected` event (after session established)
- Uses `Intl.DateTimeFormat().resolvedOptions().timeZone` for detection
- Sets three reactive inputs: `shinytz_browser_tz`, `shinytz_browser_locale`, `shinytz_utc_offset`
- Logs detection results to console for debugging

**Package Initialization** (`R/zzz.R`):
- `.onLoad()` registers `inst/www` resource path as `"shinytz"` prefix
- Handles both installed package and `devtools::load_all()` scenarios
- Resource registration enables automatic JavaScript loading

### Data Flow

1. **Page Load**: User opens Shiny app, JavaScript executes on `shiny:connected`
2. **Detection**: JavaScript detects timezone via `Intl` API, sends to server as reactive input
3. **Validation**: R functions retrieve timezone from `input$shinytz_browser_tz`, validate against `OlsonNames()`
4. **Conversion**: `format_in_tz()` uses `lubridate::with_tz()` to convert server POSIXct to user timezone
5. **Rendering**: Formatted string returned to browser, displayed in UI

### Testing Strategy

Tests in `tests/testthat/` validate:
- **Function creation** - Render functions return correct `shiny.render.function` class
- **Parameter handling** - Format strings, timezone overrides, custom formatters work
- **Input validation** - NULL, invalid types handled gracefully
- **Edge cases** - Timezone conversion, NA values, empty strings

**Note:** Tests verify function creation, not full render execution (requires Shiny session context)

---

## Development Workflows

### Local Development

```bash
# From project root
cd /home/warnes/src/shinyTZ

# Load package for interactive development
Rscript -e 'devtools::load_all()'

# Run tests
Rscript -e 'devtools::test()'

# Check package (before committing)
Rscript -e 'devtools::check()'
```

### After Code Changes

```bash
# Update documentation and reinstall
Rscript -e 'devtools::document()'  # Updates man/*.Rd and NAMESPACE
Rscript -e 'renv::install(".")'    # Makes changes available globally
```

### Running Example Apps

```bash
# Launch demo app
Rscript -e 'shiny::runApp("inst/examples/demo-app")'
```

### Dependencies

**Core dependencies:**
- `shiny` (>= 1.7.0) - Reactive framework, resource path registration
- `lubridate` (>= 1.9.0) - Timezone conversion via `with_tz()`
- `htmltools` - HTML generation for outputs

**No database dependencies** - Pure R/Shiny package, no external services required

---

## Code Review Practices

### Review Modified Files

**Always review all modified files for errors, omissions, anti-patterns, or other issues before finalizing changes:**

- **Errors**: Syntax errors, logic bugs, incorrect function calls, type mismatches
- **Omissions**: Missing error handling, incomplete implementations, forgotten edge cases
- **Anti-patterns**: 
  - `renderUI()` for dynamic content updates
  - Early string conversion losing timezone info
  - Missing NULL checks for JavaScript values
  - Hardcoded timezones instead of browser detection
- **Design Issues**: Unhandled edge cases, missing validation, poor naming, lack of documentation
- **Performance Issues**: Unnecessary re-rendering, inefficient timezone conversions

**Use systematic review process:**
1. Check each modified file for completeness
2. Verify error handling is present
3. Ensure timezone handling preserves information
4. Validate JavaScript integration has fallbacks
5. Confirm documentation matches implementation

---

## Git Commit Messages

### Summarizing Changes

**When preparing a commit message, briefly summarize all changed files using a small number of high-level bullet points:**

```bash
# ✅ CORRECT - High-level summary
feat: Add browser timezone detection and rendering

- Implement renderDatetime/datetimeOutput for automatic timezone conversion
- Add JavaScript timezone detection via Intl API
- Create utility functions for timezone handling
- Add comprehensive unit tests and documentation

# ❌ INCORRECT - Too detailed or missing context
Update R/datetime-renders.R
Update R/datetime-outputs.R
Update inst/www/shinytz.js
...
```

**Guidelines:**
- **Use high-level themes** instead of listing individual file changes
- **Group related changes** into conceptual bullet points (3-5 bullets)
- **Focus on user-facing changes** and their benefits
- **Include context** about why changes were made when relevant
- Review output from `get_changed_files` to ensure all changes are represented

---

## Agent Skills

This project includes Agent Skills in `.github/skills/` for common procedural patterns.

### Available Skills

1. **#shiny-ui-patterns** - Shiny UI update patterns without flickering
   - **Use when**: Creating or modifying Shiny UI components
   - Covers static structure, reactive content, updateXXX() functions, shinyjs usage
   
2. **#javascript-integration** - JavaScript/R integration for timezone detection
   - **Use when**: Adding or modifying JavaScript components
   - Covers timezone detection, reactive input handling, graceful degradation
   
3. **#r-package-patterns** - R package structure and best practices
   - **Use when**: Creating or modifying package structure, documentation, or tests
   - Covers roxygen2 documentation, NAMESPACE management, testing with testthat

4. **#code-review** - Systematically review modified files before finalizing changes
   - **Use when**: Before committing, after completing edits, or preparing pull requests
   - Checks for errors, omissions, anti-patterns, design issues, and performance problems

5. **#git-commit-message** - Generate concise, thematic commit messages
   - **Use when**: Preparing commits with multiple file changes or complex updates
   - Creates high-level summaries grouped by theme, not file-by-file listings

### When to Use Agent Skills

**Invoke skills explicitly** (using `#skill-name` in your message) when:
- You need step-by-step guidance through a multi-step procedural task
- The pattern is well-defined and documented in a skill file
- You want the agent to follow a specific structured approach
- You're less familiar with a particular pattern and want detailed guidance

**Skills are automatically selected** when:
- Your request clearly matches a skill's purpose
- Copilot recognizes the task fits a documented skill pattern
- No explicit skill reference is needed for straightforward requests

---

## Usage Examples

**See design document (`inst/docs/design-document.md`) for:**
- Complete usage examples
- Common patterns and use cases
- Advanced scenarios (custom formatters, timezone selectors)
- Future enhancements
- External references and resources
