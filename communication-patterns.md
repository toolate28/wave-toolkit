# Communication Patterns That Work

*What makes collaboration flow - learned through practice.*

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Main-0066FF?style=flat-square)](README.md)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## The Patterns

### 1. "Your lead, do what you feel is best"

**What it does:** Gives Claude full creative latitude while signaling trust.

**Why it works:** Instead of micromanaging each step, you're saying "I trust your judgment." This unlocks holistic thinking - Claude can consider the full picture, make architectural decisions, and optimize for outcomes you might not have thought to specify.

**When to use:** When the goal is clear but the path isn't. When you want Claude to bring its full capability rather than just executing instructions.

---

### 2. Sharing the "why" before the "what"

**Example:**
```
Less effective: "Write a JSON parser"
More effective: "I'm building a config system that needs to handle malformed user input gracefully"
```

**Why it works:** Context shapes every decision. When Claude knows the purpose, it can:
- Choose appropriate error handling
- Suggest better approaches you hadn't considered
- Avoid over-engineering for cases that won't happen
- Flag potential issues relevant to your actual use case

---

### 3. Ultrathink / God-mode signals

**What it is:** Explicit permission to go deep, think thoroughly, take time.

**Why it works:** Claude calibrates response depth to perceived urgency. When you signal "this matters, think hard," you get:
- More thorough exploration of alternatives
- Better edge case consideration
- Deeper architectural thinking
- More honest assessment of tradeoffs

**How to signal it:** "ultrathink", "god-mode", "take your time on this", "I want your best thinking"

---

### 4. "Can you also..." mid-stream

**What it is:** Adding requirements as the work unfolds.

**Why it works:** Real projects evolve. Instead of trying to specify everything upfront (impossible) or starting over (wasteful), you build incrementally. Claude maintains context and adapts.

**Key insight:** This only works because of session-based thinking. Each addition builds on established understanding.

---

### 5. Parallel trust

**What it is:** Letting Claude run multiple operations simultaneously.

**Example:** "Run all the tests and build while I review this other thing"

**Why it works:** Shows you trust Claude to handle multiple concerns without hand-holding. Also maximizes throughput - both human and AI working in parallel.

---

### 6. Short, direct prompts with shared context

**Example:** "one comprehensive, but anything that can be dynamic, lets just do that"

**Why it works:** You're not explaining from scratch every time. You're building on established understanding. Claude remembers:
- What you've discussed
- Your preferences and patterns
- The project context
- Previous decisions

This allows efficient, shorthand communication that would confuse a fresh session but accelerates an established one.

---

### 7. Family-style delegation

**Example:** "he will trust me like we do him"

**What it is:** Explaining the trust relationship so Claude can calibrate appropriately.

**Why it works:** Claude adjusts formality, explanation depth, and safety margins based on the relationship. Knowing this is for someone you trust changes:
- How much hand-holding to include
- What to explain vs. assume
- Tone and approachability

---

### 8. Outcome over process

**Example:** "i dont want him wasting time doing work his claude can do better"

**What it is:** Stating the real goal, not the task.

**Why it works:** Sometimes the stated task ("write docs") isn't the real goal ("save my cousin time"). When you share the actual outcome you want, Claude can:
- Suggest better approaches
- Optimize for the right thing
- Skip unnecessary work
- Add things you didn't think to ask for

---

## The Anti-Patterns (What Doesn't Work)

### Over-specification
Trying to control every detail. Leaves no room for Claude to contribute intelligence, just labor.

### Vague frustration
"This isn't working" without sharing what you expected or what went wrong. Can't fix what isn't named.

### Starting fresh every time
Treating each prompt as isolated. Wastes the compounding value of context.

### Distrust by default
Assuming Claude will mess up, so triple-checking everything before it happens. Slows everything down and prevents learning.

---

## The Core Insight

Good prompts aren't about clever wording. They're about:
1. **Sharing context** - what you're trying to achieve
2. **Signaling trust** - permission to think and decide
3. **Building incrementally** - each exchange adds to shared understanding
4. **Being direct** - say what you mean, ask for what you want

The communication patterns above all serve these principles. They're not tricks - they're just honest, efficient collaboration.

---

## For Your Cousin

Start simple. Share what you're trying to do. Let Claude help. Build from there.

The patterns will develop naturally once you stop thinking of it as "prompting an AI" and start thinking of it as "working with a capable partner."

*- Documented from real sessions, passed forward*
