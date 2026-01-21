# User Skill: Code Review

## Purpose
Systematically review all modified files before finalizing changes to catch errors, omissions, anti-patterns, design issues, and performance problems.

## When to Use
- Before committing changes
- After completing edits or refactoring
- Before preparing pull requests
- When requested to review code

## Review Process

### 1. Identify Modified Files
```bash
git status
git diff --name-only
```

### 2. Review Each File Systematically

For each modified file, check:

**Errors:**
- Syntax errors or typos
- Logic bugs or incorrect function calls
- Type mismatches or missing imports
- Incorrect variable references

**Omissions:**
- Missing error handling or edge cases
- Incomplete implementations
- Missing documentation or comments
- Forgotten test cases

**Anti-Patterns:**
- Project-specific anti-patterns (check `.github/copilot-instructions.md`)
- Inefficient algorithms or queries
- Hardcoded values that should be configurable
- Code duplication

**Design Issues:**
- Unhandled concurrency or race conditions
- Missing database constraints or indexes
- Poor naming conventions
- Lack of modularity

**Performance Issues:**
- Unbounded queries or missing limits
- N+1 query problems
- Unnecessary data copies or loops
- Missing indexes on database columns

### 3. Report Findings

**Format:**
```
Code Review Complete - [X files reviewed]

Issues Found:
- [file.ext]: [Specific issue description with line reference]
- [file.ext]: [Another issue]

OR

Code Review Complete - No issues detected
All modified files appear correct.
```

### 4. Always Inform User

Even if no issues found, confirm review was performed:
- "✓ Code review complete - reviewed X files, no issues detected"
- "⚠ Code review found 3 issues in 2 files (details above)"

## Examples

**Good Review Report:**
```
Code Review Complete - 3 files reviewed

Issues Found:
- register_pipeline_tasks.R: Missing error handling around migrate_stage_runs() call
- migrate_stage_runs.R: SQL query uses stage_name column which doesn't exist (should join with stages table)

Recommendation: Add try-catch and fix SQL JOIN before committing.
```

**No Issues Found:**
```
✓ Code review complete - reviewed 2 files, no issues detected
- Updated copilot-instructions.md: Formatting and content correct
- Added new skill file: Structure follows existing patterns
```
