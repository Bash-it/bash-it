# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bash-it is a collection of community Bash commands and scripts for Bash 3.2+, providing a framework for aliases, themes, plugins, and completions. It's structured as a modular system where components can be individually enabled or disabled.

## Architecture

### Core Components

- **bash_it.sh**: Main entry point that initializes the framework
- **lib/**: Core libraries providing utilities, logging, helpers, and appearance functions
- **scripts/reloader.bash**: Component loader that sources enabled components
- **install.sh**: Installation script with interactive and silent modes
- **enabled/**: Symlinks to active components from available/ directories

### Component Types

1. **Aliases** (`aliases/available/`): Command shortcuts and convenience functions
2. **Plugins** (`plugins/available/`): Extended functionality and integrations
3. **Completions** (`completion/available/`): Tab completion definitions
4. **Themes** (`themes/`): Prompt customizations and visual styles

### Loading Order

1. Libraries (except appearance)
2. Global enabled directory
3. Enabled aliases, plugins, completions
4. Theme files (if BASH_IT_THEME is set)
5. Custom files from BASH_IT_CUSTOM directory

## Development Commands

### Testing
```bash
# Run all tests using BATS (Bash Automated Testing System)
test/run

# Run specific test suites
test/run test/bash_it test/completion test/plugins

# Tests require git submodules to be initialized
git submodule init && git submodule update
```

### Linting and Code Quality

The project uses a gradual pre-commit system implementation via `clean_files.txt` allow-list:

```bash
# Run pre-commit hooks only on allow-listed clean files
./lint_clean_files.sh

# Run pre-commit hooks on all files (for testing new coverage)
pre-commit run --all-files

# Manual shellcheck on bash files
shellcheck **/*.bash

# Format shell scripts
shfmt -w **/*.bash
```

**Gradual Linting System**:
- `clean_files.txt`: Allow-list of files/directories that pass all linting rules
- `lint_clean_files.sh`: Runs pre-commit hooks only on allow-listed files
- When modifying files NOT in `clean_files.txt`, ensure they pass linting before adding them to the allow-list
- Before creating a PR, add newly cleaned files to `clean_files.txt` to expand coverage
- This system allows gradual improvement of code quality across the large codebase

**Vendor Directory Policy**:
- Files in `vendor/` are treated as immutable external dependencies
- Pre-commit hooks exclude vendor files via `.pre-commit-config.yaml` global exclude pattern
- `clean_files.txt` does not include vendor shell scripts, only `.gitattributes`
- CI and local linting will skip vendor files entirely

### Component Management
```bash
# Enable/disable components
bash-it enable alias git
bash-it enable plugin history
bash-it enable completion docker

# Show available components
bash-it show aliases
bash-it show plugins  
bash-it show completions

# Search components
bash-it search docker
```

## Key Configuration

### Environment Variables
- `BASH_IT`: Base directory path
- `BASH_IT_THEME`: Active theme name
- `BASH_IT_CUSTOM`: Custom components directory
- `BASH_IT_LOG_PREFIX`: Logging prefix for debug output

### File Structure Conventions
- Available components: `{type}/available/{name}.{type}.bash`
- Enabled components: `{type}/enabled/{name}.{type}.bash` (symlinks)
- Custom components: `custom/{name}.bash`
- Themes: `themes/{name}/`

## Development Guidelines

### Git Workflow
- **NEVER commit directly to master branch**
- Master should always stay in sync with `origin/master`
- Always create a feature branch for new work: `git checkout -b feature/feature-name`
- Keep feature branches focused on a single issue/feature
- Create separate branches for separate features
- Push feature branches with upstream tracking: `git push -u fork feature-branch-name`
  - This allows manual pushes later with just `git push`
  - Use `--force-with-lease` for rebased branches

### Component Development
- Use composure metadata: `about`, `group`, `author`, `example`
- Follow naming convention: `{name}.{type}.bash`
- Test components before submitting
- Components should be modular and not conflict with others

### Testing Components
- Each component type has dedicated test files in `test/`
- Use BATS framework for shell script testing
- Test files follow pattern: `{component}.bats`

### Code Standards
- Use shellcheck for linting
- Follow existing code style in the repository
- Add appropriate metadata using composure functions
- Components should handle missing dependencies gracefully
- **Prefix sensitive commands with `command`** to bypass user aliases:
  - `command mv` instead of `mv` (users may have `alias mv='mv -i'`)
  - `command grep` instead of `grep` (users may have custom grep flags)
  - `command rm` instead of `rm` (users may have `alias rm='rm -i'`)
  - Apply to any command that could be aliased and break core functionality
  - This prevents surprises from user's alias configurations in bash-it core functions
- **Use parameter expansion with default for potentially unset variables**:
  - `${VARIABLE-}` instead of `$VARIABLE` when variable may be unset
  - Prevents errors when `set -u` is active in user's shell
  - Examples: `${BASH_VERSION-}`, `${HOME-}`, `${PATH-}`
  - Critical for variables checked in conditionals: `if [ -n "${BASH_VERSION-}" ]`
  - This defensive practice ensures scripts work regardless of user's shell options

## Project Planning & Roadmaps

Strategic planning documents are maintained in `docs/plans/`:

- **[Quick Reference](docs/plans/bash-it-quick-reference.md)** - TL;DR summary of current issues and action items
- **[Comprehensive Issue Analysis](docs/plans/bash-it-issues-comprehensive-analysis.md)** - Detailed breakdown of all open issues with categorization and recommendations
- **[2025 Roadmap](docs/plans/bash-it-roadmap-2025.md)** - 6-month technical debt reduction plan with phases and success metrics

These documents guide ongoing maintenance, issue triage, and code quality improvements.
