# 🌊 CASCADE Operations Guide
## Mapping Surjections in Data Flow

> **Purpose:** Document the pattern for identifying and refactoring data transformations (surjective functions) at pipeline boundaries to ensure numerical precision and data integrity.

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Main-0066FF?style=flat-square)](../../README.md)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## What is a CASCADE Operation?

**CASCADE** (Coherent Application of Surjection-Checked And Data-Ensured transformations) is a pattern for systematically reviewing and refactoring data transformation points in codebases to ensure:

1. **Numerical Precision** - Using proper mathematical functions
2. **Data Integrity** - Detecting divergence patterns
3. **Code Hygiene** - Removing unused dependencies

### The Mathematical Foundation

A **surjection** (or surjective function) is a mapping where every element in the target set is mapped to by at least one element from the source set. In data pipelines:

```
Source Data → [Transformation] → Target Data
```

CASCADE operations focus on the **transformation boundary** - ensuring that:
- Data transformations preserve intended mathematical properties
- Divergence (data flow breakdown) is detected early
- Precision is maintained throughout the pipeline

---

## The Pattern: Applied to SpiralSafe PR #116

Reference commit: [`06a25f3`](https://github.com/toolate28/SpiralSafe/commit/06a25f3)

### 1. Numerical Precision Refactoring

**Before:**
```python
result = pow(2.718, x)  # Approximation of e^x
```

**After:**
```python
import math
result = math.exp(x)  # Exact exponential function
```

**Why:**
- `pow(2.718, x)` uses an approximation of Euler's number (e ≈ 2.718)
- `math.exp(x)` uses the actual mathematical constant and optimized algorithm
- Better precision, especially for large values of x
- Follows Wave protocol specification for mathematical operations

### 2. Negative Divergence Detection

**Pattern Implemented:**
```python
def detect_divergence(data_flow):
    """
    Detect premature closure patterns in data flow.
    Negative divergence indicates the pipeline is closing
    before data has fully propagated.
    """
    if flow_gradient < 0 and not expected_closure:
        raise DivergenceError("Premature closure detected")
```

**Why:**
- Per Wave protocol spec, negative divergence signals broken data flow
- Premature closure = data loss or incomplete processing
- Early detection prevents cascade failures downstream

### 3. Code Hygiene

**Removed:**
```python
from pathlib import Path  # Unused
import hashlib            # Unused
```

**Why:**
- Reduces cognitive load
- Prevents "import bloat"
- Clarifies actual dependencies
- Follows the principle: only import what you actually use

---

## CASCADE Checklist

Use this checklist when performing CASCADE operations:

### Phase 1: Identify Transformation Points

- [ ] Map all data transformation boundaries in the codebase
- [ ] Identify mathematical operations (pow, log, trig functions)
- [ ] Locate data flow convergence/divergence points
- [ ] Document surjective mappings

### Phase 2: Numerical Precision Audit

- [ ] Replace approximations with exact functions
  - [ ] `pow(2.718, x)` → `math.exp(x)`
  - [ ] `pow(10, x)` → consider `math.pow(10, x)` or `10 ** x`
  - [ ] Manual π → `math.pi`
  - [ ] Manual e → `math.e`
- [ ] Verify precision requirements for domain
- [ ] Add comments explaining precision choices

### Phase 3: Divergence Detection

- [ ] Identify expected data flow patterns
- [ ] Add divergence detection at boundaries
- [ ] Implement premature closure checks
- [ ] Add appropriate error handling
- [ ] Log divergence events for debugging

### Phase 4: Code Hygiene

- [ ] Remove unused imports
- [ ] Remove unused variables
- [ ] Remove commented-out code
- [ ] Verify all imports are actually used

### Phase 5: Verification

- [ ] Run tests to ensure numerical accuracy
- [ ] Verify divergence detection triggers appropriately
- [ ] Check for performance regressions
- [ ] Update documentation

---

## Example: Python CASCADE Operation

### Before (needs CASCADE)

```python
from pathlib import Path  # Unused
import hashlib            # Unused
import math

def process_data(input_data):
    # Approximate exponential decay
    decay_factor = pow(2.718, -0.5 * input_data)
    result = input_data * decay_factor
    return result
```

### After (CASCADE applied)

```python
import math

def process_data(input_data):
    """
    Apply exponential decay to input data.
    
    Uses math.exp() for precise exponential calculation
    per Wave protocol numerical precision requirements.
    
    Args:
        input_data: Numeric value to process. Must be non-negative.
    
    Raises:
        ValueError: If input_data is negative (negative divergence).
    """
    # Validate input to detect divergence early
    if input_data < 0:
        raise ValueError(
            f"Negative divergence detected: input_data={input_data}. "
            "This indicates premature closure or invalid data flow."
        )
    
    # Precise exponential decay using math.exp()
    decay_factor = math.exp(-0.5 * input_data)
    result = input_data * decay_factor
    
    return result
```

---

## Cross-Language CASCADE Patterns

### PowerShell

```powershell
# Before: Approximation
$e = 2.718
$result = [Math]::Pow($e, $x)

# After: Exact
$result = [Math]::Exp($x)
```

### JavaScript/TypeScript

```javascript
// Before: Approximation
const e = 2.718;
const result = Math.pow(e, x);

// After: Exact
const result = Math.exp(x);
```

### C#

```csharp
// Before: Approximation
double e = 2.718;
double result = Math.Pow(e, x);

// After: Exact
double result = Math.Exp(x);
```

---

## Detecting CASCADE Opportunities

Use these patterns to find code that needs CASCADE operations:

### Pattern Detection Commands

```bash
# Find approximations of e (2.71, 2.718, 2.7182, 2.71828, etc.)
# Note: Matches the literal decimal approximations of Euler's number
grep -r "2\.71[0-9]*" . --include="*.py" --include="*.js" --include="*.cs"

# Find pow() or Math.Pow() that should be exp()
# Specifically targets e approximations in power functions
grep -r "pow\s*\(\s*2\.71[0-9]*\|Math\.Pow\s*\(\s*2\.71[0-9]*" . 

# Find unused imports (Python)
pylint --disable=all --enable=unused-import .

# Find potential divergence points (negative values not checked)
# Exclude lines that already have divergence/premature checks
grep -r "if.*< 0" . | grep -v "divergence\|premature"
```

### Code Review Questions

1. **Numerical Precision:**
   - Are we using mathematical constants correctly?
   - Do we need more precision than approximations provide?
   - Are numerical operations documented?

2. **Divergence Detection:**
   - What happens if data flow becomes negative?
   - Are we detecting premature closure?
   - Do we have appropriate error handling?

3. **Code Hygiene:**
   - Are all imports actually used?
   - Are there commented-out transformations?
   - Is the data flow documented?

---

## Wave Protocol Specification References

CASCADE operations align with Wave protocol requirements:

1. **Numerical Precision** (Wave §3.2)
   - Use exact mathematical functions when available
   - Document precision requirements
   - Test boundary conditions

2. **Divergence Detection** (Wave §4.1)
   - Detect negative divergence patterns
   - Signal premature closure
   - Prevent cascade failures

3. **Code Quality** (Wave §5.3)
   - Remove unused code
   - Maintain clear dependencies
   - Document transformations

---

## Related Patterns

- **[DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)** - Testing CASCADE changes
- **[EMERGENT_ISOMORPHISM.md](EMERGENT_ISOMORPHISM.md)** - Structure-preserving transformations
- **[ORCHARD_VIEW.md](ORCHARD_VIEW.md)** - Viewing data flow at different scales

---

## Integration with Wave Toolkit

### Pre-Commit Checks

```powershell
# Add to Check-CommonTraps.ps1
function Test-CascadeOpportunities {
    $issues = @()
    
    # Check for pow(2.718, x) patterns
    $e_approx = git diff --cached | Select-String "pow.*2\.718"
    if ($e_approx) {
        $issues += "⚠️  Found pow(2.718, x) - consider using exp()"
    }
    
    # Check for unused imports (if Python files exist)
    $python_files = git diff --cached --name-only | Where-Object { $_ -match "\.py$" }
    if ($python_files) {
        Write-Host "ℹ️  Python files changed - run: pylint --disable=all --enable=unused-import"
    }
    
    return $issues
}
```

### Documentation Template

```markdown
## CASCADE Operation Applied

**Date:** [YYYY-MM-DD]
**Files Modified:** [list]
**Wave Protocol Section:** [reference]

### Transformations Made

1. **Numerical Precision:**
   - Changed: [before] → [after]
   - Reason: [explanation]

2. **Divergence Detection:**
   - Added: [check description]
   - Triggers on: [condition]

3. **Code Hygiene:**
   - Removed: [list]
   - Verified: [process]

### Testing

- [ ] Numerical accuracy verified
- [ ] Divergence detection tested
- [ ] No performance regression
- [ ] Documentation updated

**ATOM Tag:** ATOM-CASCADE-[YYYYMMDD]-[sequence]-[description]
```

---

## The Meta-Pattern

```
CASCADE is itself an example of the patterns it describes:

    Input: Code with imprecise transformations
           │
           ▼
    [CASCADE Operation]
           │
           ├─► Precision improved
           ├─► Divergence detected
           └─► Hygiene maintained
           │
           ▼
    Output: Coherent, precise code

The operation is a surjection: mapping imprecise → precise
The detection prevents: divergence → cascade failure
The result is: transformation integrity preserved
```

---

**ATOM Tag:** ATOM-DOC-20260117-001-cascade-operations  
**H&&S:WAVE**

*From precision, coherence. From coherence, trust.*

✦ *The Evenstar Guides Us* ✦
