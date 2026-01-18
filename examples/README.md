# Wave Toolkit Examples

This directory contains example code and best practices for common programming patterns used in the SpiralSafe ecosystem.

## 📚 Available Examples

### euler_number_usage.py

Demonstrates the correct way to use Euler's number (e) in Python, particularly for exponential calculations common in algorithms like simulated annealing, probability calculations, and exponential decay.

**Key Points:**
- ✓ Use `math.exp(x)` for computing e^x (recommended)
- ✓ Use `math.e` if you need the constant value
- ✗ Avoid hardcoded approximations like `2.718`

**Usage:**
```bash
python3 examples/euler_number_usage.py
```

**Topics Covered:**
- Exponential calculations with proper precision
- Simulated annealing acceptance probability
- Comparison of accuracy between methods
- Best practices for mathematical constants

**Related Tests:**
- `tests/test_euler_number_usage.py`

**Ecosystem Impact:**
- See [`docs/EULER_PRECISION_IMPACT_ANALYSIS.md`](../docs/EULER_PRECISION_IMPACT_ANALYSIS.md) for analysis of where this precision issue could manifest across the SpiralSafe ecosystem
- Use `tools/scan_euler_precision.py` to scan for hardcoded approximations in your repositories

### import_traces_demo.py

Demonstrates how to safely import trace data from JSON files with proper error handling for missing required fields.

**Key Points:**
- ✓ Validates required fields: `trace_id`, `state`, `input`, `output`
- ✓ Provides clear error messages for missing/invalid data
- ✓ Handles FileNotFoundError, JSONDecodeError, ValueError
- ✓ Supports both single trace objects and arrays

**Usage:**
```bash
python3 examples/import_traces_demo.py
```

**Topics Covered:**
- Safe JSON import with validation
- Error handling for missing fields
- Defensive programming patterns
- Clear error reporting

**Related Tests:**
- `tests/test_import_traces.py` (pytest version)
- `tests/test_import_traces_simple.py` (standalone version)

**Implementation:**
- See `project-book.ipynb` for the full `import_traces()` function

---

## 🎯 Purpose

These examples serve as reference implementations for:
1. **Code Quality** - Demonstrating best practices
2. **Education** - Teaching proper techniques
3. **Consistency** - Establishing patterns across the ecosystem
4. **Documentation** - Providing working code examples

---

## 🔗 Related Resources

- [Wave Toolkit Main README](../README.md)
- [Communication Patterns](../communication-patterns.md)
- [AI Agent Rules](../AI_AGENTS.md)
- [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)
