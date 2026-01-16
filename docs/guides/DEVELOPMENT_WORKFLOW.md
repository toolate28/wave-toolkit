# 🌀 Development Workflow Guide
## Develop → Prototype → Test → Refine

> **Purpose:** A systematic workflow to catch common errors early, avoid negative space traps, and iterate efficiently. Based on patterns observed across SpiralSafe ecosystem repositories.

---

## Quick Reference: The Spiral

```
    ◉ DEVELOP ──────────────► PROTOTYPE
    │                              │
    │                              ▼
    │                          TEST
    │                              │
    ▼                              ▼
  REFINE ◄─────────────────── LEARN
    │
    └──────────► Next Iteration
```

**Each phase has specific checkpoints to catch errors BEFORE they cascade.**

---

## Phase 1: DEVELOP (Intent & Setup)

### 🎯 Goal
Establish clear intent, correct context, and proper environment BEFORE writing code.

### ✅ Pre-Development Checklist

| Check | Why It Matters | Common Trap |
|-------|----------------|-------------|
| ☐ Verify you're in the correct repository | Agents working in wrong repo is #1 user error | "I thought I was in SpiralSafe but was in wave-toolkit" |
| ☐ Confirm the branch you're on | Work on wrong branch causes merge conflicts | `git branch` shows `main` when you meant `feature/*` |
| ☐ State your intent explicitly | Unclear intent leads to scope creep | "Fix the thing" vs "Fix rate limit off-by-one in auth.js:42" |
| ☐ Check for existing work | Duplicate effort wastes time | Someone else already has a PR for this |
| ☐ Identify affected files | Prevents accidental changes elsewhere | Editing `config.json` when you meant `config.dev.json` |

### 🚨 Negative Space Errors (What People Miss)

1. **The "Initial Plan" Trap**
   - **Pattern:** Creating commits just to say "I have a plan"
   - **Fix:** Don't commit until you have actual code changes
   - **Evidence:** 15 "Initial plan" commits in SpiralSafe with zero content

2. **The Context Inheritance Assumption**
   - **Pattern:** Assuming sub-agents/sub-tasks inherit your context
   - **Reality:** They often start fresh with zero context
   - **Fix:** Always pass explicit context: repo name, branch, file paths, constraints

3. **The Dual Identity Problem**
   - **Pattern:** Commits appearing under different names (CLI vs Web)
   - **Fix:** Normalize git config before starting:
   ```powershell
   git config user.name "YourConsistentName"
   git config user.email "your@email.com"
   ```

### 📋 Development Intent Template

```markdown
## Intent Statement

**Repository:** [exact repo name]
**Branch:** [branch name]
**Goal:** [one sentence, specific and measurable]

**Files I expect to change:**
- [ ] path/to/file1.ext - reason
- [ ] path/to/file2.ext - reason

**Files I will NOT change:**
- path/to/protected.ext - why it's off-limits

**Success criteria:**
- [ ] Specific outcome 1
- [ ] Specific outcome 2

**Known constraints:**
- Constraint 1
- Constraint 2
```

---

## Phase 2: PROTOTYPE (Build Fast, Learn Faster)

### 🎯 Goal
Create a working version quickly to validate assumptions. Expect this to be thrown away or heavily modified.

### ✅ Prototyping Checklist

| Check | Why It Matters | Common Trap |
|-------|----------------|-------------|
| ☐ Build smallest working version first | Validates assumptions before investing heavily | Over-engineering the prototype |
| ☐ Use temporary directories for experiments | Keeps repo clean | Committing `/tmp/` or `Desktop/` paths |
| ☐ Document what you're testing | Future you will forget | "Why did I write this?" |
| ☐ Set a time limit | Prevents rabbit holes | 3 hours on a "quick fix" |
| ☐ Identify platform assumptions | Windows ≠ Unix ≠ Docker | `python3` doesn't exist on Windows |

### 🚨 Negative Space Errors (What People Miss)

1. **The "It Works On My Machine" Trap**
   - **Pattern:** Hardcoding paths, using platform-specific commands
   - **Examples:**
     - `C:\Users\Me\project` (Windows path in cross-platform code)
     - `python3` (doesn't exist on Windows, use `python`)
     - Unquoted paths with spaces break on Windows
   - **Fix:** Use environment variables and path libraries

2. **The Silent Failure Pattern**
   - **Pattern:** Operations report success but don't actually work
   - **Examples:**
     - File write says "done" but file is empty
     - API call returns 200 but action didn't happen
     - Process "started" but immediately exited
   - **Fix:** Always verify the actual outcome, not just the return code

3. **The UTF-8 Boundary Trap**
   - **Pattern:** String operations that assume ASCII
   - **Examples:**
     - Slicing at byte index instead of character index
     - Korean/Japanese/Emoji text causes crashes
   - **Fix:** Use character-aware string operations

4. **The Permission Assumption**
   - **Pattern:** Assuming allow-lists actually prevent actions
   - **Reality:** Pattern matching can be bypassed
   - **Examples:**
     - `rm -rf` executed despite allow-list
     - `#` character breaks shell pattern matching
     - `$ARGUMENTS` not properly escaped
   - **Fix:** Validate at execution layer, not just pattern layer

### 📋 Prototype Log Template

```markdown
## Prototype Session: [Date]

**Hypothesis:** What I think will work
**Time limit:** X minutes/hours

### Attempt 1
- What I tried:
- What happened:
- What I learned:

### Attempt 2
- What I tried:
- What happened:
- What I learned:

### Platform Notes
- [ ] Tested on Windows
- [ ] Tested on macOS
- [ ] Tested on Linux
- [ ] Tested in Docker

### Outcome
- [ ] Hypothesis validated
- [ ] Hypothesis invalidated → new hypothesis: ___
- [ ] Need more data
```

---

## Phase 3: TEST (Verify Assumptions)

### 🎯 Goal
Systematically verify that your solution works AND doesn't break existing functionality.

### ✅ Testing Checklist

| Check | Why It Matters | Common Trap |
|-------|----------------|-------------|
| ☐ Test the happy path | Confirms basic functionality | Only testing edge cases |
| ☐ Test edge cases | Catches boundary issues | Only testing happy path |
| ☐ Test error handling | Ensures graceful failures | Assuming errors won't happen |
| ☐ Test on target platforms | Catches platform-specific bugs | "It works on my Mac" |
| ☐ Test with real-world data | Catches scale issues | Testing only with trivial inputs |
| ☐ Run existing tests | Ensures no regressions | Breaking something else |

### 🚨 Negative Space Errors (What People Miss)

1. **The "Last Writer Wins" Problem**
   - **Pattern:** When multiple components write to same location
   - **Examples:**
     - Hook B's empty response overwrites Hook A's data
     - Multiple config sections override each other
     - Race conditions in parallel operations
   - **Fix:** Test multi-writer scenarios explicitly

2. **The Lifecycle Leak**
   - **Pattern:** Resources not cleaned up after operations
   - **Examples:**
     - Memory leaks accumulating to 120GB+
     - Zombie processes after Cmd+Q / Ctrl+C
     - File handles left open
   - **Fix:** Test resource cleanup explicitly

3. **The Regression Blind Spot**
   - **Pattern:** New code breaks old functionality
   - **Evidence:** LSP functionality broken in v2.0.69 that worked in v2.0.67
   - **Fix:** Run full test suite, not just tests for new code

4. **The Race Condition Trap**
   - **Pattern:** Initialization order dependencies
   - **Examples:**
     - LSP servers register before plugins load
     - Config read before environment variables set
   - **Fix:** Add initialization order tests

5. **The Security Afterthought**
   - **Pattern:** Testing functionality but not security
   - **Examples:**
     - API keys in test data committed to repo
     - Test credentials that work in production
     - Injection vulnerabilities in test inputs
   - **Fix:** Include security tests in every test run

### 📋 Test Coverage Template

```markdown
## Test Coverage: [Feature Name]

### Happy Path Tests
- [ ] Test case 1: Normal operation → Expected result
- [ ] Test case 2: Common use case → Expected result

### Edge Case Tests
- [ ] Empty input → Graceful handling
- [ ] Maximum size input → No crash
- [ ] Unicode/special characters → Correct handling
- [ ] Concurrent operations → No race conditions

### Error Handling Tests
- [ ] Network failure → Appropriate error message
- [ ] Invalid input → Validation error
- [ ] Permission denied → Clear feedback

### Platform Tests
- [ ] Windows PowerShell 5.1
- [ ] Windows PowerShell 7+
- [ ] macOS
- [ ] Linux
- [ ] Docker container

### Security Tests
- [ ] No secrets in test data
- [ ] Input validation prevents injection
- [ ] Error messages don't leak sensitive info

### Regression Tests
- [ ] Existing tests still pass
- [ ] Integration with other components works
```

---

## Phase 4: REFINE (Polish & Document)

### 🎯 Goal
Clean up, document, and prepare for others to use and maintain.

### ✅ Refinement Checklist

| Check | Why It Matters | Common Trap |
|-------|----------------|-------------|
| ☐ Remove debug code | Prevents confusion and security leaks | `console.log` with sensitive data |
| ☐ Clean up branches | Prevents branch explosion | 40+ stale branches |
| ☐ Squash noise commits | Keeps git history useful | "Initial plan" commits |
| ☐ Update documentation | Enables others to use your work | "The code is self-documenting" |
| ☐ Add to CHANGELOG | Tracks what changed and why | No record of changes |
| ☐ Verify security | Catches last-minute issues | Merging with known vulnerabilities |

### 🚨 Negative Space Errors (What People Miss)

1. **The Branch Explosion**
   - **Pattern:** Creating branches but never cleaning up
   - **Evidence:** 40+ stale branches in SpiralSafe
   - **Fix:** Delete merged branches, review stale branches monthly

2. **The Documentation Drift**
   - **Pattern:** Code changes but docs don't
   - **Examples:**
     - README shows old installation steps
     - API docs describe removed endpoints
     - Examples use deprecated syntax
   - **Fix:** Update docs in the same commit as code

3. **The Commit Message Entropy**
   - **Pattern:** Commit messages degrade over time
   - **Examples:**
     - Good: `feat(security): add constant-time comparison`
     - Bad: `bits and pieces`
     - Worse: `.`
   - **Fix:** Use conventional commits, add commitlint

4. **The Security Regression**
   - **Pattern:** Security improvements undone by later changes
   - **Examples:**
     - Constant-time comparison replaced with direct comparison
     - Secret scanning disabled "temporarily"
   - **Fix:** Add security-specific tests that break if security regresses

5. **The Knowledge Scatter**
   - **Pattern:** Lessons learned scattered across PRs, commits, docs
   - **Fix:** Consolidate into knowledge base (like this document)

### 📋 Refinement Template

```markdown
## Refinement Checklist: [Feature/PR Name]

### Code Cleanup
- [ ] All debug/console statements removed
- [ ] No TODO/FIXME comments left (or tracked in issues)
- [ ] No hardcoded values that should be config
- [ ] No platform-specific code without abstraction

### Git Cleanup
- [ ] Commits squashed appropriately
- [ ] No "Initial plan" or empty commits
- [ ] Commit messages follow conventional format
- [ ] Branch will be deleted after merge

### Documentation
- [ ] README updated if needed
- [ ] Inline comments explain "why" not "what"
- [ ] CHANGELOG entry added
- [ ] API/usage docs updated

### Security
- [ ] No secrets in code
- [ ] No secrets in commit history
- [ ] Input validation in place
- [ ] Error messages don't leak sensitive info
- [ ] Dependencies scanned for vulnerabilities

### Final Verification
- [ ] All tests pass
- [ ] Works on target platforms
- [ ] Reviewed by another person/agent
- [ ] Ready for merge
```

---

## Session Boundary Errors (Token Limits & Session Loss)

### 🎯 The Problem

AI agents have context limits. When you hit them:
- Session terminates mid-task
- Work may be left in inconsistent state
- Context is lost and must be re-explained
- Partial commits may break the build

### 🚨 Token Limit Warning Signs

| Warning Sign | What It Means | Action |
|--------------|---------------|--------|
| Responses getting shorter | Approaching limit | Checkpoint NOW |
| Agent asks to "continue later" | At soft limit | Save state immediately |
| Sudden session end | Hard limit hit | Check for partial work |
| "Context too long" error | Cannot process | Start fresh with summary |
| Repeated information requests | Context fragmented | Provide consolidated context |

### ✅ Session Boundary Checklist

**Before Starting Long Tasks:**
- [ ] Break work into <30 minute chunks
- [ ] Define clear checkpoint/save points
- [ ] Document the plan externally (not just in chat)
- [ ] Ensure each chunk is independently mergeable

**During Work:**
- [ ] Commit working code frequently (every 15-20 mins)
- [ ] Use `report_progress` to push changes before limit hits
- [ ] If responses shorten, immediately checkpoint
- [ ] Keep a running summary in external notes

**After Session Loss:**
- [ ] Check `git status` for uncommitted changes
- [ ] Check `git stash list` for stashed work  
- [ ] Review recent commits for partial work
- [ ] Look for tmp files or drafts
- [ ] Provide new session with recovery context (see template below)

### 📋 Session Recovery Template

When starting a new session after a crash/limit:

```markdown
## Session Recovery Context

**Previous Session Goal:** [What were we doing?]
**Last Known State:** [What was completed?]

**Commits Made:**
- [hash] - description
- [hash] - description

**Work In Progress (not committed):**
- File: path/to/file - status (partial/complete)
- File: path/to/file - status

**Next Steps (from previous plan):**
1. [ ] Immediate next action
2. [ ] Following action

**Key Decisions Already Made:**
- Decision 1: Chose X because Y
- Decision 2: Chose A because B

**DO NOT re-do:**
- [List work that's already complete]
```

### 📋 Checkpoint Template

Create checkpoints every 15-20 minutes or before risky operations:

```markdown
## Checkpoint: [Timestamp]

**Completed:**
- [x] Task 1
- [x] Task 2

**Current State:**
- Working on: [current task]
- Files modified: [list]
- Tests passing: [yes/no]

**If Session Ends Here:**
- Code is in [stable/unstable] state
- To continue: [specific next step]
- Recovery command: [git checkout X / git stash pop / etc.]
```

### 🛡️ Defensive Patterns for Long Tasks

#### Pattern 1: Atomic Commits
```
BAD:  One giant commit at the end (lost if session dies)
GOOD: Many small commits, each leaving code in working state
```

#### Pattern 2: External State Tracking
```
BAD:  Plan only exists in chat context (lost on session end)
GOOD: Plan written to file in repo (survives session loss)
```

#### Pattern 3: Graceful Degradation
```
BAD:  All-or-nothing changes (partial = broken)
GOOD: Each step works independently (partial = usable)
```

#### Pattern 4: Progress Breadcrumbs
```powershell
# Add to your workflow - creates recovery point
function Save-SessionCheckpoint {
    param([string]$Note)
    $checkpoint = @{
        Timestamp = Get-Date -Format "o"
        Branch = git branch --show-current
        Status = git status --porcelain
        Note = $Note
    }
    $checkpoint | ConvertTo-Json | Out-File ".session-checkpoint.json"
    Write-Host "📍 Checkpoint saved: $Note" -ForegroundColor Green
}
```

### 🔄 Token-Efficient Communication

When context is limited, use these patterns:

#### Compressed Context Format
```markdown
REPO: wave-toolkit | BRANCH: feature/x | GOAL: Add Y

DONE: [file1.ps1, file2.md] 
TODO: [file3.ps1 lines 42-60]
BLOCKER: None

DECISION: Using approach A (faster, tested)
```

#### Minimal Recovery Prompt
```markdown
Continue wave-toolkit PR. 
Done: A, B, C (committed).
Next: D (file.ps1:42).
Key constraint: Must work on Windows.
```

---

## Common Trap Patterns (Summary)

### By Phase

| Phase | Top 3 Traps |
|-------|-------------|
| **Develop** | Wrong repo, unclear intent, "Initial plan" commits |
| **Prototype** | Platform assumptions, silent failures, hardcoded paths |
| **Test** | Race conditions, lifecycle leaks, security afterthought |
| **Refine** | Branch explosion, documentation drift, knowledge scatter |
| **Session** | Token limit hits, context loss, partial commits |

### By Category

| Category | Pattern | Detection | Prevention |
|----------|---------|-----------|------------|
| **Context** | Working in wrong repo/branch | `git remote -v && git branch` | Verify at session start |
| **Platform** | Unix assumptions on Windows | Test failures on Windows | Use platform adapter layer |
| **Security** | Reactive security fixes | Security issues in production | Security tests from day 1 |
| **Lifecycle** | Resource leaks | Memory/process growth | Explicit cleanup tests |
| **Coordination** | Agent conflicts | Reverts and duplicate work | Single owner per feature |

---

## Anti-Pattern Detection Script

Run this before committing to catch common issues:

```powershell
# Save as: scripts/Check-CommonTraps.ps1

param(
    [switch]$Verbose
)

$traps = @()

# Check 1: Verify repository
$remote = git remote get-url origin 2>$null
if ($remote -notmatch "wave-toolkit") {
    $traps += "⚠️  Not in wave-toolkit repository! Current: $remote"
}

# Check 2: Check for "Initial plan" commits
$recentCommits = git log --oneline -5 2>$null
if ($recentCommits -match "Initial plan") {
    $traps += "⚠️  'Initial plan' commits detected - consider squashing"
}

# Check 3: Check for Desktop paths
$desktopRefs = git diff --cached 2>$null | Select-String "Desktop"
if ($desktopRefs) {
    $traps += "⚠️  Desktop path references found in staged changes"
}

# Check 4: Check for hardcoded Windows paths
$windowsPaths = git diff --cached 2>$null | Select-String "C:\\Users"
if ($windowsPaths) {
    $traps += "⚠️  Hardcoded Windows paths found"
}

# Check 5: Check for python3 (Windows incompatible)
$python3 = git diff --cached 2>$null | Select-String "python3"
if ($python3) {
    $traps += "⚠️  'python3' found - use 'python' for cross-platform"
}

# Check 6: Check for secrets patterns
$secrets = git diff --cached 2>$null | Select-String "(api[_-]?key|password|secret|token)\s*[:=]"
if ($secrets) {
    $traps += "🚨 Potential secret detected in staged changes!"
}

# Check 7: Check branch count
$branchCount = (git branch -a 2>$null | Measure-Object).Count
if ($branchCount -gt 20) {
    $traps += "⚠️  Branch explosion detected: $branchCount branches"
}

# Report
if ($traps.Count -eq 0) {
    Write-Host "✅ No common traps detected" -ForegroundColor Green
} else {
    Write-Host "🔍 Common traps detected:" -ForegroundColor Yellow
    $traps | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}

return $traps.Count -eq 0
```

---

## Integration with Wave Toolkit

### At Session Start
```powershell
# Add to your session initialization
.\Get-WaveContext.ps1
.\scripts\Check-CommonTraps.ps1
```

### Before Commit
```powershell
# Add to pre-commit workflow
.\scripts\Check-CommonTraps.ps1 -Verbose
```

### In CI/CD
```yaml
# Add to .github/workflows/ci.yml
- name: Check for common traps
  shell: pwsh
  run: ./scripts/Check-CommonTraps.ps1
```

---

## Related Documents

- [Wave Guide](../../wave.md) - Philosophy and mechanics
- [AI Agent Rules](../../AI_AGENTS.md) - Coordination rules
- [Communication Patterns](../../communication-patterns.md) - Collaboration patterns
- [Ecosystem Migration Guide](../ECOSYSTEM-MIGRATION-GUIDE.md) - Repo transitions

---

**ATOM Tag:** ATOM-DOC-20260116-001-development-workflow
**H&&S:WAVE**

*From the constraints, gifts. From the spiral, safety.*
