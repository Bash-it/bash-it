# Bash-it Technical Debt Reduction Roadmap 2025
**Created**: 2025-10-05
**Last Updated**: 2025-10-07
**Owner**: Maintainers
**Goal**: Reduce open issues from 32 to <10, improve code quality to 100% pre-commit clean

---

## Current State Assessment

### Health Metrics (2025-10-07 Update)
- 📊 **Open Issues**: 32 → **27** (5 closed pending PR merge)
- 🧹 **Clean Files**: ~50 files in `clean_files.txt`
- ✅ **Pre-commit Coverage**: ~15% of codebase
- ⏰ **Stale Issues**: 78% (>2 years old) - **25 remaining**
- 🐛 **Active Bugs**: ~~5~~ **1** fixable quickly (4 fixed!)
- 🎯 **Issue Response Time**: Variable (some years old)
- 🚀 **PRs Created**: **6** in 2 days

### Technical Debt Categories
1. **Code Quality**: Many files don't pass shellcheck/shfmt
2. **Issue Backlog**: 25 stale issues creating noise
3. **Documentation**: Inconsistent, incomplete
4. **Testing**: Good BATS coverage, but could expand
5. **Distribution**: Manual install only, no package managers

---

## Phase 1: Quick Wins Sprint ✅ COMPLETED (2025-10-07)
**Goal**: Fix bugs, close issues, build momentum
**Effort**: 2 days, 6 PRs created

### Tasks
- [x] #2317: Auto-detect git remote (PR #2345 - 2025-10-05)
- [x] #2248: Laravel artisan completion (PR #2349 - 2025-10-07)
- [x] #2296: Fix down4me function (PR #2350 - 2025-10-07)
- [x] #2260: Fix SSH completion @ removal (PR #2351 - 2025-10-07)
- [x] #2238: Improve uninstall script (PR #2352 - 2025-10-07)
- [x] #2216: Node version conditional display (PR #2353 - 2025-10-07)
- [ ] #2314: Rename todo alias file (TODO - 5 min)

### Success Criteria
- ✅ 6 PRs created (awaiting review/merge)
- ✅ 5 issues can be closed (pending PR merge)
- ⏳ Tests included where applicable
- ✅ Clean git history, all linting passed

### Deliverables
- Working fixes for real user problems
- Test coverage for fixed bugs
- Updated documentation where needed
- Template for future quick-win sprints

---

## Phase 2: Issue Garden Cleanup (Week 3-4)
**Goal**: Reduce noise, improve project health
**Effort**: ~4 hours

### Strategy: Aggressive Stale Issue Closure
Close issues that are:
- >2 years old with no recent activity
- Vague feature requests with no volunteers
- Questions that were never answered
- Fixed but not closed
- No longer relevant

### Execution Plan
1. **Week 3**: Draft closure messages for each issue
2. **Get maintainer approval** on closure list
3. **Week 4**: Close issues with polite template message
4. **Add labels**: "stale-closed", "reopen-if-relevant"

### Issues to Close (18 total)
**Ancient** (>4 years, likely irrelevant):
- #517: Plugin load times (2015)
- #922: Support for enhancd (2017)
- #1053: Evaluate kcov coverage (2017)
- #1207: Prompt wrap-around (2018)

**Old** (2-4 years, no activity):
- #1640: Cleanup base/general
- #1680: Document all commands
- #1693: todo plugin $TODO variable
- #1818: Move libs to vendor
- #1943: preexec performance
- #2080: Structure aliases
- #2084: Platform config question
- #2149: pyenv over SSH
- #2150: Preview help
- #2174: System alias breaks completion
- #2184: Show plugin source URI
- #2197: Preview not working
- #2202: Install shebang question

**Recent but stale** (needs repro):
- #2254: Syntax error in completion

### Success Criteria
- ✅ Open issues reduced from 32 to <15
- ✅ All remaining issues labeled appropriately
- ✅ Clear "why closed" rationale for each
- ✅ Template for future issue gardening

---

## Phase 3: Strategic Decisions (Month 2)
**Goal**: Establish clear project direction
**Effort**: Discussion + documentation

### Decisions Required

#### 1. Framework-Specific Completions (#2248, #2245)
**Question**: Accept framework-specific completions (Laravel, etc.)?
**Options**:
- A) Accept all quality completions (grow features)
- B) Only popular/maintained frameworks (selective)
- C) Reject (keep bash-it focused)

**Recommendation**: Option B - Selective acceptance
- Require: Good tests, maintained upstream, popular (>10k stars)
- Reject: Niche frameworks, unmaintained, poor code quality

#### 2. Smart Plugin Behavior (#2216)
**Question**: Should plugins auto-detect context (e.g., nvm only in Node projects)?
**Options**:
- A) Add smart detection (better UX, more complexity)
- B) Keep simple (user configures, less magic)

**Recommendation**: Option B - Keep simple
- Document how users can add conditional logic themselves
- Avoid complexity in core plugins

#### 3. Maintainer/Governance (#2214)
**Question**: Need co-maintainers? How to govern?
**Options**:
- A) Seek co-maintainers (share workload)
- B) Stay solo (full control)
- C) Create contributor tiers (core + trusted)

**Recommendation**: Option C - Tiered contributors
- Core maintainer(s): Can merge to master
- Trusted contributors: Can label, triage issues
- Contributors: Submit PRs

#### 4. Package Manager Distribution (#1819)
**Question**: Worth effort to get into Homebrew, apt, etc.?
**Options**:
- A) Full packaging effort (Homebrew, apt, yum)
- B) Homebrew only (most requested)
- C) Git install only (current)

**Recommendation**: Option B - Homebrew first
- Create Homebrew formula (2-4 hours work)
- Improves adoption significantly
- Low maintenance once set up
- Defer other package managers until demand proven

#### 5. Alias Philosophy (#825)
**Question**: How aggressive with default aliases?
**Options**:
- A) Very conservative (no common command shadowing)
- B) Current approach (some shadowing, documented)
- C) More aggressive (convenience > safety)

**Recommendation**: Option B - Current + better docs
- Keep current aliases (many users depend on them)
- Add BIG WARNING in docs about ll, la, etc.
- Add `bash-it doctor --check-conflicts` command
- Let users decide (enable/disable)

### Outcome
- All decisions documented in CLAUDE.md
- Issues closed or converted to tracked work
- Clear contributor guidelines

---

## Phase 4: Pre-commit Expansion (Month 2-3)
**Goal**: Get 80%+ of files passing pre-commit hooks
**Effort**: ~20 hours spread over 6 weeks

### Current State
- `clean_files.txt` has ~50 entries
- Remaining: ~450 bash files need cleanup
- Pre-commit hooks: shellcheck, shfmt, trailing whitespace, etc.

### Strategy: Chip Away Weekly
- **Weekly goal**: Add 10 files to `clean_files.txt`
- **Prioritize**: Most-used files first (lib/, install.sh, bash_it.sh)
- **Batch fixes**: Group similar files (all themes, all plugins of type X)

### Target Files (Priority Order)
1. **Core** (Week 1-2):
   - bash_it.sh
   - scripts/reloader.bash
   - All files in lib/
   
2. **Install/Uninstall** (Week 3):
   - install.sh (partially done)
   - uninstall.sh

3. **Popular Plugins** (Week 4-5):
   - plugins/available/base.plugin.bash
   - plugins/available/git.plugin.bash
   - plugins/available/docker.plugin.bash
   - plugins/available/nvm.plugin.bash

4. **Themes** (Week 6-7):
   - Focus on most popular themes first
   - bobby, powerline, atomic, etc.

5. **Completions** (Week 8-9):
   - System completions
   - Popular tool completions

6. **Aliases** (Week 10+):
   - Lower priority (users can disable)
   - Fix as time permits

### Success Criteria
- ✅ 80% of files in `clean_files.txt`
- ✅ All core files (lib/, scripts/) clean
- ✅ Install scripts clean
- ✅ Top 10 plugins/themes clean

---

## Phase 5: Documentation Refresh (Month 3-4)
**Goal**: Improve docs incrementally as we work
**Effort**: ~10 hours

### Key Documentation Needs
1. **README.md**: Update with current state
2. **CONTRIBUTING.md**: Clear guidelines for PRs
3. **CLAUDE.md**: Document decisions, patterns
4. **Wiki**: Troubleshooting common issues

### Approach: Doc-as-you-go
- Fix bug → Update relevant docs
- Add feature → Update examples
- Close stale issue → Document decision

### Priority Docs
1. Pre-commit hook usage (for contributors)
2. Plugin development guide
3. Theme development guide
4. Troubleshooting guide
5. Performance optimization guide

---

## Phase 6: Testing Expansion (Month 4-5)
**Goal**: Increase test coverage for critical paths
**Effort**: ~15 hours

### Current Testing
- BATS framework in place
- Good coverage of core functionality
- Some plugins/completions lack tests

### Testing Priorities
1. **Core Functions**: lib/helpers.bash functions
2. **Bug Fixes**: Every bug fix gets a test
3. **Plugins**: At least smoke tests for all
4. **Completions**: Test completion generation

### Success Criteria
- ✅ All functions in lib/ have tests
- ✅ All fixed bugs have regression tests
- ✅ CI runs tests on every PR
- ✅ Test coverage >70%

---

## Phase 7: Packaging & Distribution (Month 5-6)
**Goal**: Get bash-it into Homebrew (if decision approved)
**Effort**: ~8 hours initial + ongoing maintenance

### Homebrew Formula Steps
1. Create formula in homebrew-core
2. Define installation steps
3. Add update mechanism
4. Add uninstall support
5. Submit PR to Homebrew

### Requirements
- Semantic versioning (start tagging releases)
- Stable release process
- Update mechanism (bash-it update needs to work)
- CI to test formula

### Success Criteria
- ✅ Homebrew formula accepted
- ✅ Users can `brew install bash-it`
- ✅ Formula auto-updates with releases
- ✅ Documented in README

---

## Success Metrics & KPIs

### Issue Health
| Metric | Current | 1 Month | 3 Months | 6 Months |
|--------|---------|---------|----------|----------|
| Open Issues | 32 | <15 | <10 | <10 |
| Stale Issues | 25 | 0 | 0 | 0 |
| Response Time | Variable | <1 week | <3 days | <3 days |
| Issues with Labels | 50% | 100% | 100% | 100% |

### Code Quality
| Metric | Current | 1 Month | 3 Months | 6 Months |
|--------|---------|---------|----------|----------|
| Clean Files | 50 | 100 | 250 | 400+ |
| Pre-commit Coverage | 15% | 30% | 60% | 80%+ |
| Shellcheck Pass | ~15% | ~30% | ~60% | 80%+ |
| Test Coverage | Good | Good | Better | 70%+ |

### Project Health
| Metric | Current | 1 Month | 3 Months | 6 Months |
|--------|---------|---------|----------|----------|
| Documentation | Fair | Good | Good | Excellent |
| Contributor Guidelines | Basic | Clear | Clear | Comprehensive |
| Distribution | Git only | Git only | Git only | + Homebrew |
| Active Contributors | Few | Growing | Growing | Community |

---

## Risk Management

### Risks & Mitigations

#### Risk: Closing issues angers contributors
**Mitigation**: 
- Polite closure messages
- Clear "reopen if relevant" policy
- Respond promptly to reopens

#### Risk: Pre-commit slows down contributors
**Mitigation**:
- Clear docs on running pre-commit
- Auto-fix where possible (shfmt -w)
- Allow incremental improvement

#### Risk: Feature decisions split community
**Mitigation**:
- Be transparent about reasoning
- Accept feedback, be willing to reverse
- Plugins are optional - defaults matter less

#### Risk: Packaging creates maintenance burden
**Mitigation**:
- Start with Homebrew only
- Automate release process
- Only pursue if demand is real

---

## Timeline Summary

```
Month 1: Quick Wins + Issue Cleanup
  Week 1-2: Fix 5 bugs
  Week 3-4: Close 18 stale issues

Month 2: Decisions + Pre-commit Start
  Week 5-6: Make strategic decisions
  Week 7-8: Clean core files

Month 3: Pre-commit Expansion
  Week 9-12: Add 40+ files to clean_files.txt

Month 4: Documentation + Testing
  Week 13-16: Improve docs, add tests

Month 5-6: Polish + Optional Packaging
  Week 17-20: Continue cleanup
  Week 21-24: Homebrew formula (if approved)
```

---

## Resource Requirements

### Time Investment
- **Maintainer**: 2-4 hours/week decision-making, review
- **Contributor(s)**: 4-8 hours/week implementation
- **Total**: ~6-12 hours/week for 6 months

### Skills Needed
- Bash scripting (existing)
- Testing with BATS (existing)
- Git workflow (existing)
- GitHub Actions (light, for packaging)
- Homebrew packaging (learn, ~4 hours)

---

## Next Steps

1. **Review this roadmap** with maintainer(s)
2. **Approve Phase 1** Quick Wins sprint
3. **Decide on stale issue closure** approach
4. **Make strategic decisions** (Phase 3)
5. **Start executing** week by week

---

## Questions for Maintainer

1. Approve Quick Wins sprint? (5 bug fixes)
2. Approve stale issue closure? (18 issues)
3. Which strategic decisions need discussion?
4. What's the priority: features vs. cleanup?
5. Interest in co-maintainers/trusted contributors?
6. Should I start Phase 1 immediately?
