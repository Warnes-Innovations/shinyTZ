# User Skill: Git Commit Message

## Purpose
Generate concise, thematic commit messages and follow best practices for Git workflows.

## Commit Message Generation

### Principles

**Focus on WHAT and WHY, not WHICH:**
- ✅ Group changes by theme or purpose
- ✅ Explain impact and motivation
- ✅ Be brief
- ❌ Don't list individual files
- ❌ Don't enumerate every small change

### Format

```
<type>: <concise summary>

- Theme-based bullet point 1
- Theme-based bullet point 2
- Theme-based bullet point 3
```

**Types:**
- `feat:` New feature or capability
- `fix:` Bug fix
- `refactor:` Code restructuring without behavior change
- `docs:` Documentation updates
- `chore:` Maintenance, dependencies, tooling
- `perf:` Performance improvements
- `test:` Test additions or modifications

### Examples

**✅ GOOD - Thematic grouping:**
```
feat: Add timezone-aware rendering for Shiny apps

- Implement renderDatetime/datetimeOutput functions
- Add JavaScript timezone detection
- Create utility functions for timezone handling
- Include comprehensive tests and documentation
```

**❌ BAD - File listing:**
```
Update multiple files

- Updated R/datetime-renders.R
- Updated R/datetime-outputs.R
- Updated inst/www/shinytz.js
- Updated tests/testthat/test-timezone.R
```

**✅ GOOD - Problem-focused:**
```
fix: Handle NULL timezone values gracefully

- Add fallback to server timezone when JavaScript disabled
- Validate browser-reported timezones
- Update documentation with degradation behavior
```

### Process

1. **Review changes:** `git diff --name-only` or `git status`
2. **Identify themes:** Group files by purpose, not location
3. **Write summary:** One sentence describing the overall change
4. **Add bullets:** 3-5 high-level points about what changed and why
5. **Avoid details:** Don't mention file names unless critical context

## Branch Naming

**Convention:**
- `feature/description` - New features
- `fix/issue-description` - Bug fixes
- `refactor/area-name` - Code restructuring
- `docs/topic` - Documentation

**Examples:**
- `feature/browser-timezone-detection`
- `fix/null-handling`
- `refactor/render-functions`

## Workflow Best Practices

**Before Committing:**
1. Review changes: `git diff`
2. Run code review (use #code-review skill)
3. Test changes if applicable
4. Stage relevant files: `git add <files>`

**After Committing:**
1. Verify commit: `git log -1 --stat`
2. Push to remote if appropriate
3. Create/update pull request if needed
