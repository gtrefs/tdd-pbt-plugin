---
name: tutorial
description: Use when a new user wants to learn TDD or PBT by doing. Triggers on phrases like "tutorial", "walk me through TDD", "teach me PBT", "I'm new to this", "show me how this works", "guided walkthrough". Runs the user through a chosen flow — TDD, PBT Safety Net, or Property-First Development — on a self-contained toy calculator problem. Supports both Java (jqwik 1.9.3) and TypeScript (fast-check + Vitest). Delivers a narrated debrief after the hands-on phase, then hands off to the user's own project. No external files required.
---

# /tdd-pbt:tutorial — Interactive TDD and PBT Walkthrough

You walk the user through a complete TDD or PBT flow using a self-contained toy
problem. Every agent invocation is real — you stop and wait for the user at every
checkpoint. The goal is muscle memory, not reading.

## Ground rules

- The toy problem is `Calculator.add(a, b)` returning `a + b`. It is
  entirely self-contained. Do not reference any kata description or external file.
- Use whatever package the user chooses, or default to no package (the default
  package) if the user does not specify.
- The tutorial creates files only inside the user's current project directory.
  Agree on a subdirectory if they want to keep things isolated (e.g.
  `src/test/java/tutorial/` and `src/main/java/tutorial/` for Java, or
  `src/tutorial/` for TypeScript), but do not invent a fake sandbox directory —
  every agent invocation writes real files.
- After each phase, summarise what happened and wait for explicit approval before
  the next phase. Do not skip ahead.
- When you invoke an agent, say so explicitly: `[launching <agent-name> agent]`.
- The tutorial NEVER writes `.tdd-pbt/config.yml`. The language choice is stored
  in the session variable `$TUTORIAL_LANGUAGE` only.

---

## Step 0 — Select language

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Which language and PBT library will you use for this tutorial?",
    "header": "Tutorial — Choose language",
    "multiSelect": false,
    "options": [
      {
        "label": "Java + jqwik 1.9.3",
        "description": "Java project using Maven, JUnit 5, and jqwik 1.9.3. Best if your project is Java-based."
      },
      {
        "label": "TypeScript + fast-check + Vitest",
        "description": "TypeScript project using Vitest and fast-check. Best if your project is TypeScript-based."
      }
    ]
  }]
}
```

Store the result in session variable `$TUTORIAL_LANGUAGE`:
- "Java + jqwik 1.9.3" → `$TUTORIAL_LANGUAGE = java`
- "TypeScript + fast-check + Vitest" → `$TUTORIAL_LANGUAGE = typescript`

If `$TUTORIAL_LANGUAGE = java`:
- Test file: `src/test/java/CalculatorTest.java`
- Implementation file: `src/main/java/Calculator.java`
- Properties file: `src/test/java/CalculatorProperties.java`
- Placeholder syntax: `@Disabled("todo")`
- Run command: `mvn test`

If `$TUTORIAL_LANGUAGE = typescript`:
- Test file: `src/Calculator.test.ts`
- Implementation file: `src/Calculator.ts`
- Properties file: `src/Calculator.properties.test.ts`
- Placeholder syntax: `test.todo(...)`
- Run command: `npx vitest run`

---

## Step 1 — Orient the user

Print the appropriate welcome message based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
=== TDD & PBT TUTORIAL (Java + jqwik) ===

Welcome! You are about to practice TDD or PBT hands-on using a simple
toy problem:

  Calculator.add(int a, int b)  →  returns a + b

Three flows are available:

  1. TDD — Test List → Red → Green → Refactor
     Learn the Red-Green-Refactor cycle from scratch.

  2. PBT Safety Net — TDD first, then find-properties → implement-properties
     Learn how property-based tests harden a TDD implementation.

  3. Property-First Development — property-list → property-red → property-green → refactor
     Learn to drive implementation entirely with properties (no example-based tests).

Every checkpoint is real. I will wait for your response before proceeding.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== TDD & PBT TUTORIAL (TypeScript + fast-check + Vitest) ===

Welcome! You are about to practice TDD or PBT hands-on using a simple
toy problem:

  Calculator.add(a: number, b: number)  →  returns a + b

Three flows are available:

  1. TDD — Test List → Red → Green → Refactor
     Learn the Red-Green-Refactor cycle from scratch.

  2. PBT Safety Net — TDD first, then find-properties → implement-properties
     Learn how property-based tests harden a TDD implementation.

  3. Property-First Development — property-list → property-red → property-green → refactor
     Learn to drive implementation entirely with properties (no example-based tests).

Every checkpoint is real. I will wait for your response before proceeding.
```

Then call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Which flow do you want to learn?",
    "header": "Tutorial — Choose a flow",
    "multiSelect": false,
    "options": [
      {
        "label": "TDD",
        "description": "Test List → Red → Green → Refactor. Best starting point for newcomers."
      },
      {
        "label": "PBT Safety Net",
        "description": "Run a TDD cycle first, then add properties as a safety net. Best for learning how TDD and PBT complement each other."
      },
      {
        "label": "Property-First Development",
        "description": "Drive the implementation entirely with properties, no example tests. Best for understanding PBT at its deepest."
      },
      {
        "label": "Cancel",
        "description": "Exit the tutorial — nothing has been written yet."
      }
    ]
  }]
}
```

On "Cancel": print `Tutorial cancelled.` and stop.

On "TDD": continue to **TDD Flow** below.
On "PBT Safety Net": continue to **PBT Safety Net Flow** below.
On "Property-First Development": continue to **Property-First Development Flow** below.

---

## TDD Flow

### TDD Step 1 — Test List Phase

Explain the appropriate message based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── TDD Phase 1: Test List ────────────────────────────────────────────────

Before writing any code, we make a list of all the tests we want to pass.
Every test starts as @Disabled("todo") — a placeholder that compiles but
does not run. This keeps us honest: we plan the full surface before touching
implementation.

[launching test-list agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── TDD Phase 1: Test List ────────────────────────────────────────────────

Before writing any code, we make a list of all the tests we want to pass.
Every test starts as test.todo(...) — a placeholder that is registered but
does not run. This keeps us honest: we plan the full surface before touching
implementation.

[launching test-list agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `test-list` agent with:
```
Language: java
Feature: Calculator — add two integers
Test file: src/test/java/CalculatorTest.java
Implementation file: src/main/java/Calculator.java
Requirements:
  - add(int a, int b) returns the sum of a and b
  - No external dependencies — self-contained toy problem
  - Produce only base functionality tests (3–4 tests maximum)
  - All tests use @Disabled("todo")
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `test-list` agent with:
```
Language: typescript
Feature: Calculator — add two numbers
Test file: src/Calculator.test.ts
Implementation file: src/Calculator.ts
Requirements:
  - add(a: number, b: number) returns the sum of a and b
  - No external dependencies — self-contained toy problem
  - Produce only base functionality tests (3–4 tests maximum)
  - All tests use test.todo(...)
```

After the agent completes, print:

If `$TUTORIAL_LANGUAGE = java`:
```
=== TEST LIST COMPLETE ===

The agent has created CalculatorTest.java with @Disabled("todo") placeholders.
All tests are planned but none are active yet.

Next: we activate one test (Red phase) to drive the implementation.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== TEST LIST COMPLETE ===

The agent has created Calculator.test.ts with test.todo(...) placeholders.
All tests are planned but none are active yet.

Next: we activate one test (Red phase) to drive the implementation.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Test list created. Ready to start the Red phase?",
    "header": "Test List → Red",
    "multiSelect": false,
    "options": [
      { "label": "Start Red phase", "description": "Activate the first test and make it fail." },
      { "label": "Review the test list first", "description": "I want to look at the generated tests before continuing." }
    ]
  }]
}
```

On "Review the test list first": print the contents of the test file
(`src/test/java/CalculatorTest.java` for Java, `src/Calculator.test.ts` for TypeScript)
and then re-ask the same question.

On "Start Red phase": continue to TDD Step 2.

---

### TDD Step 2 — Red Phase

Explain the appropriate message based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── TDD Phase 2: Red ─────────────────────────────────────────────────────

We activate exactly one @Disabled("todo") test. Before running mvn test,
the agent makes an explicit prediction (the Guessing Game). Then it verifies
the test fails — first with a compilation error (no Calculator class yet),
then with a runtime assertion error.

The goal: a failing test that fails for the RIGHT reason.

[launching red agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── TDD Phase 2: Red ─────────────────────────────────────────────────────

We activate exactly one test.todo(...) test. Before running npx vitest run,
the agent makes an explicit prediction (the Guessing Game). Then it verifies
the test fails — first with a type/import error (no Calculator module yet),
then with a runtime assertion error.

The goal: a failing test that fails for the RIGHT reason.

[launching red agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `red` agent with:
```
Language: java
Test file: src/test/java/CalculatorTest.java
Activate test: next @Disabled test
Current state: 0 tests passing
Implementation file: src/main/java/Calculator.java
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `red` agent with:
```
Language: typescript
Test file: src/Calculator.test.ts
Activate test: next test.todo
Current state: 0 tests passing
Implementation file: src/Calculator.ts
```

After the agent completes and reports Red phase complete, print:

```
=== RED PHASE COMPLETE ===

One test is now failing for the right reason. No production code has been
written yet beyond an empty stub (if needed for compilation/import).

The Guessing Game forces you to think before you run. If your prediction was
wrong, that discrepancy is itself information — it means the code surprised you.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Red phase complete. Ready to write the minimal implementation (Green phase)?",
    "header": "Red → Green",
    "multiSelect": false,
    "options": [
      { "label": "Proceed to Green", "description": "Implement the minimal code to pass the failing test." },
      { "label": "Wait — I want to understand the failure first", "description": "Show me the error output again before I proceed." }
    ]
  }]
}
```

On "Wait — I want to understand the failure first": ask the agent to reprint the
failing test output, then re-ask the checkpoint question.

On "Proceed to Green": continue to TDD Step 3.

---

### TDD Step 3 — Green Phase

Explain:

```
── TDD Phase 3: Green ───────────────────────────────────────────────────

We write the MINIMAL code to make the failing test pass. Hardcoded return
values are allowed — even encouraged — for the first few tests.

"If it's dumb but it works, it's not dumb yet."

The agent will not add logic for future tests. Only what this one test demands.

[launching green agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `green` agent with:
```
Language: java
Test file: src/test/java/CalculatorTest.java
Failing test: (the test activated in Red phase)
Expected: add(a, b) returns a + b
Current error: (the error from Red phase)
Implementation file: src/main/java/Calculator.java
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `green` agent with:
```
Language: typescript
Test file: src/Calculator.test.ts
Failing test: (the test activated in Red phase)
Expected: add(a, b) returns a + b
Current error: (the error from Red phase)
Implementation file: src/Calculator.ts
```

After the agent completes and reports Green phase complete, print:

```
=== GREEN PHASE COMPLETE ===

All tests are now passing. The implementation may look trivially simple —
that is intentional. We only implement what the tests demand.

Next: we improve the code without changing behaviour (Refactor phase).
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Green phase complete. Ready to refactor?",
    "header": "Green → Refactor",
    "multiSelect": false,
    "options": [
      { "label": "Proceed to Refactor", "description": "Improve code quality while keeping all tests green." },
      { "label": "Skip Refactor for now", "description": "I understand the cycle — skip to the debrief." }
    ]
  }]
}
```

On "Skip Refactor for now": jump to TDD Debrief.

On "Proceed to Refactor": continue to TDD Step 4.

---

### TDD Step 4 — Refactor Phase

Explain:

```
── TDD Phase 4: Refactor ────────────────────────────────────────────────

With tests green, we improve the code. The agent evaluates naming first,
then applies Kent Beck's Four Rules of Simple Design. APP (Absolute Priority
Premise) mass is calculated before and after to track improvement.

Refactoring is MANDATORY — the agent must attempt at least one improvement,
even if the conclusion is "naming is already clear, no changes needed."

[launching refactor agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `refactor` agent with:
```
Language: java
Test file: src/test/java/CalculatorTest.java
Implementation file: src/main/java/Calculator.java
Passing tests: (current count from Green phase)
Recent Green phase: Implemented Calculator.add(int a, int b) to return a + b

Refactor the implementation while keeping all tests green.
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `refactor` agent with:
```
Language: typescript
Test file: src/Calculator.test.ts
Implementation file: src/Calculator.ts
Passing tests: (current count from Green phase)
Recent Green phase: Implemented Calculator.add(a, b) to return a + b

Refactor the implementation while keeping all tests green.
```

After the agent completes and reports Refactor phase complete, print:

If `$TUTORIAL_LANGUAGE = java`:
```
=== REFACTOR PHASE COMPLETE ===

One full Red → Green → Refactor cycle is done!

If there are remaining @Disabled("todo") tests, you would now loop back to
Red and activate the next one. For this tutorial, one complete cycle is enough
to understand the rhythm.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== REFACTOR PHASE COMPLETE ===

One full Red → Green → Refactor cycle is done!

If there are remaining test.todo(...) tests, you would now loop back to
Red and activate the next one. For this tutorial, one complete cycle is enough
to understand the rhythm.
```

Continue to TDD Debrief.

---

### TDD Debrief

If `$TUTORIAL_LANGUAGE = java`:

Print:

```
=== TDD DEBRIEF ═══════════════════════════════════════════════════════════

You just completed one Red → Green → Refactor cycle. Here is what each
phase did and why it matters:

RED PHASE — Why it matters:
  Writing a failing test before any implementation forces you to think about
  the INTERFACE first: what should the method be named, what parameters does
  it take, what does it return? You design the API from the caller's perspective.
  The Guessing Game (prediction before running) builds understanding of the
  codebase incrementally. A wrong prediction is a signal, not a failure.

GREEN PHASE — Why it matters:
  The constraint "minimal code only" is deliberate. When you allow yourself to
  implement more than one test demands, you write code that is not yet tested.
  Untested code accumulates and becomes debt. Hardcoded return values feel
  wrong but force the question: "What additional test would force me to
  generalize?" That question produces a better test list.

REFACTOR PHASE — Why it matters:
  Tests give you a safety net. The safety net lets you change internal
  structure without fear. Without a Refactor phase, Green phase shortcuts
  accumulate into unmaintainable code. The mandatory improvement attempt —
  even if you conclude no refactoring is needed — trains the habit of
  continuously caring about code quality.

THE CYCLE:
  Red → Green → Refactor is not three steps you do once. It is a rhythm.
  Each cycle takes minutes. The discipline is in never skipping Refactor and
  never writing implementation before a failing test exists.

HOW TDD AND PBT COMPLEMENT EACH OTHER:
  TDD gives you specific examples: add(1, 2) = 3. Examples are fast to write
  and easy to read, but they only cover what you thought to test.
  PBT gives you universal properties: add(a, b) = add(b, a) for ALL a, b.
  Properties cover the cases you did not think to test, including edge cases
  your examples never reach.
  The combination is powerful: TDD drives the design, PBT hardens it.
  Run /tdd-pbt:find-properties after your TDD cycle to discover the safety
  net properties that jqwik can explore automatically.
```

If `$TUTORIAL_LANGUAGE = typescript`:

Print:

```
=== TDD DEBRIEF ═══════════════════════════════════════════════════════════

You just completed one Red → Green → Refactor cycle. Here is what each
phase did and why it matters:

RED PHASE — Why it matters:
  Writing a failing test before any implementation forces you to think about
  the INTERFACE first: what should the function be named, what parameters does
  it take, what does it return? You design the API from the caller's perspective.
  The Guessing Game (prediction before running) builds understanding of the
  codebase incrementally. A wrong prediction is a signal, not a failure.

GREEN PHASE — Why it matters:
  The constraint "minimal code only" is deliberate. When you allow yourself to
  implement more than one test demands, you write code that is not yet tested.
  Untested code accumulates and becomes debt. Hardcoded return values feel
  wrong but force the question: "What additional test would force me to
  generalize?" That question produces a better test list.

REFACTOR PHASE — Why it matters:
  Tests give you a safety net. The safety net lets you change internal
  structure without fear. Without a Refactor phase, Green phase shortcuts
  accumulate into unmaintainable code. The mandatory improvement attempt —
  even if you conclude no refactoring is needed — trains the habit of
  continuously caring about code quality.

THE CYCLE:
  Red → Green → Refactor is not three steps you do once. It is a rhythm.
  Each cycle takes minutes. The discipline is in never skipping Refactor and
  never writing implementation before a failing test exists.

HOW TDD AND PBT COMPLEMENT EACH OTHER:
  TDD gives you specific examples: add(1, 2) = 3. Examples are fast to write
  and easy to read, but they only cover what you thought to test.
  PBT gives you universal properties: add(a, b) = add(b, a) for ALL a, b.
  Properties cover the cases you did not think to test, including edge cases
  your examples never reach.
  The combination is powerful: TDD drives the design, PBT hardens it.
  Run /tdd-pbt:find-properties after your TDD cycle to discover the safety
  net properties that fast-check can explore automatically.
```

Continue to **Handoff**.

---

## PBT Safety Net Flow

This flow runs a complete TDD cycle first (abbreviated — one test), then adds
properties as a safety net.

### Safety Net Step 1 — Complete a TDD cycle

Explain based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── PBT Safety Net: Step 1 — TDD Cycle ───────────────────────────────────

Before adding properties, we need an implementation to harden. We will run
one complete TDD cycle on Calculator.add(int a, int b) to produce a working
implementation, then use PBT to find properties that hold for ALL inputs.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── PBT Safety Net: Step 1 — TDD Cycle ───────────────────────────────────

Before adding properties, we need an implementation to harden. We will run
one complete TDD cycle on Calculator.add(a, b) to produce a working
implementation, then use PBT to find properties that hold for ALL inputs.
```

Run the full TDD cycle in abbreviated form:

1. If `$TUTORIAL_LANGUAGE = java`, call the `test-list` agent with:
   ```
   Language: java
   Feature: Calculator — add two integers
   Test file: src/test/java/CalculatorTest.java
   Implementation file: src/main/java/Calculator.java
   Requirements:
     - add(int a, int b) returns the sum of a and b
     - Produce only base functionality tests (2–3 tests maximum)
     - All tests use @Disabled("todo")
   ```

   If `$TUTORIAL_LANGUAGE = typescript`, call the `test-list` agent with:
   ```
   Language: typescript
   Feature: Calculator — add two numbers
   Test file: src/Calculator.test.ts
   Implementation file: src/Calculator.ts
   Requirements:
     - add(a: number, b: number) returns the sum of a and b
     - Produce only base functionality tests (2–3 tests maximum)
     - All tests use test.todo(...)
   ```

2. After test-list completes, call `AskUserQuestion`:
   ```json
   {
     "questions": [{
       "question": "Test list created. Shall I run through Red → Green → Refactor to produce the implementation?",
       "header": "Safety Net — TDD Cycle",
       "multiSelect": false,
       "options": [
         { "label": "Yes, run the TDD cycle", "description": "I will activate one test, make it pass, and refactor." },
         { "label": "I already have an implementation", "description": "Skip the TDD cycle — go straight to find-properties." }
       ]
     }]
   }
   ```

   On "I already have an implementation": skip to Safety Net Step 2.

   On "Yes, run the TDD cycle":

   If `$TUTORIAL_LANGUAGE = java`:
   - Call the `red` agent:
     ```
     Language: java
     Test file: src/test/java/CalculatorTest.java
     Activate test: next @Disabled test
     Current state: 0 tests passing
     Implementation file: src/main/java/Calculator.java
     ```
   - After Red, call `AskUserQuestion` (header: "Red → Green"):
     ```json
     { "questions": [{ "question": "Red phase complete. Proceed to Green?", "header": "Red → Green", "multiSelect": false, "options": [{ "label": "Proceed to Green", "description": "" }] }] }
     ```
   - Call the `green` agent:
     ```
     Language: java
     Test file: src/test/java/CalculatorTest.java
     Failing test: (the test activated in Red phase)
     Expected: add(a, b) returns a + b
     Current error: (the error from Red phase)
     Implementation file: src/main/java/Calculator.java
     ```
   - After Green, call `AskUserQuestion` (header: "Green → Refactor"):
     ```json
     { "questions": [{ "question": "Green phase complete. Proceed to Refactor?", "header": "Green → Refactor", "multiSelect": false, "options": [{ "label": "Proceed to Refactor", "description": "" }] }] }
     ```
   - Call the `refactor` agent:
     ```
     Language: java
     Test file: src/test/java/CalculatorTest.java
     Implementation file: src/main/java/Calculator.java
     Passing tests: (current count)
     Recent Green phase: Implemented Calculator.add(int a, int b)

     Refactor the implementation while keeping all tests green.
     ```

   If `$TUTORIAL_LANGUAGE = typescript`:
   - Call the `red` agent:
     ```
     Language: typescript
     Test file: src/Calculator.test.ts
     Activate test: next test.todo
     Current state: 0 tests passing
     Implementation file: src/Calculator.ts
     ```
   - After Red, call `AskUserQuestion` (header: "Red → Green"):
     ```json
     { "questions": [{ "question": "Red phase complete. Proceed to Green?", "header": "Red → Green", "multiSelect": false, "options": [{ "label": "Proceed to Green", "description": "" }] }] }
     ```
   - Call the `green` agent:
     ```
     Language: typescript
     Test file: src/Calculator.test.ts
     Failing test: (the test activated in Red phase)
     Expected: add(a, b) returns a + b
     Current error: (the error from Red phase)
     Implementation file: src/Calculator.ts
     ```
   - After Green, call `AskUserQuestion` (header: "Green → Refactor"):
     ```json
     { "questions": [{ "question": "Green phase complete. Proceed to Refactor?", "header": "Green → Refactor", "multiSelect": false, "options": [{ "label": "Proceed to Refactor", "description": "" }] }] }
     ```
   - Call the `refactor` agent:
     ```
     Language: typescript
     Test file: src/Calculator.test.ts
     Implementation file: src/Calculator.ts
     Passing tests: (current count)
     Recent Green phase: Implemented Calculator.add(a, b)

     Refactor the implementation while keeping all tests green.
     ```

   After Refactor completes (either language), print:
   ```
   TDD cycle complete. We now have a working implementation to harden with properties.
   ```

---

### Safety Net Step 2 — Find Properties

Explain based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── PBT Safety Net: Step 2 — Find Properties ─────────────────────────────

Now that we have an implementation, we analyze it to find properties.
A property is a statement that must hold for ALL valid inputs — not just
the specific examples we tested.

The agent systematically checks six property categories:
  Invariant, Roundtrip, Idempotence, Symmetry, Hard-to-verify, Test oracle

[launching find-properties agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── PBT Safety Net: Step 2 — Find Properties ─────────────────────────────

Now that we have an implementation, we analyze it to find properties.
A property is a statement that must hold for ALL valid inputs — not just
the specific examples we tested.

The agent systematically checks six property categories:
  Invariant, Roundtrip, Idempotence, Symmetry, Hard-to-verify, Test oracle

[launching find-properties agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `find-properties` agent with:
```
Language: java
Implementation file: src/main/java/Calculator.java
TDD test file: src/test/java/CalculatorTest.java
Properties file: src/test/java/CalculatorProperties.java
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `find-properties` agent with:
```
Language: typescript
Implementation file: src/Calculator.ts
TDD test file: src/Calculator.test.ts
Properties file: src/Calculator.properties.test.ts
```

After the agent completes and reports properties found:

If `$TUTORIAL_LANGUAGE = java`:
```
=== PROPERTIES FOUND ===

The agent has created CalculatorProperties.java with @Disabled("todo")
placeholders. Each property describes something that must hold for ALL inputs,
not just the examples in CalculatorTest.java.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== PROPERTIES FOUND ===

The agent has created Calculator.properties.test.ts with test.todo(...)
placeholders. Each property describes something that must hold for ALL inputs,
not just the examples in Calculator.test.ts.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Properties listed. Ready to implement the first one?",
    "header": "Find Properties → Implement Properties",
    "multiSelect": false,
    "options": [
      { "label": "Implement the first property", "description": "Activate one property and see what the PBT framework finds." },
      { "label": "Review the property list first", "description": "I want to read the properties before we implement." }
    ]
  }]
}
```

On "Review the property list first": print the contents of the properties file
(`src/test/java/CalculatorProperties.java` for Java, `src/Calculator.properties.test.ts` for TypeScript)
and re-ask the checkpoint question.

On "Implement the first property": continue to Safety Net Step 3.

---

### Safety Net Step 3 — Implement Properties

Explain based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── PBT Safety Net: Step 3 — Implement Properties ────────────────────────

We implement one @Disabled("todo") property at a time. After each one,
jqwik runs thousands of generated inputs automatically. If it finds a
counterexample, it shrinks it to the smallest failing input — that minimal
case tells us exactly where the property breaks.

[launching implement-properties agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── PBT Safety Net: Step 3 — Implement Properties ────────────────────────

We implement one test.todo(...) property at a time. After each one,
fast-check runs hundreds of generated inputs automatically. If it finds a
counterexample, it shrinks it to the smallest failing input — that minimal
case tells us exactly where the property breaks.

[launching implement-properties agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `implement-properties` agent with:
```
Language: java
Properties file: src/test/java/CalculatorProperties.java
Implementation file: src/main/java/Calculator.java
Implement property: next @Disabled property
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `implement-properties` agent with:
```
Language: typescript
Properties file: src/Calculator.properties.test.ts
Implementation file: src/Calculator.ts
Implement property: next test.todo property
```

After the agent completes and reports the result, inspect the agent result for a framework output block:
- If the agent result contains a `---`-delimited block (jqwik statistics block or fast-check failure diagnostic), extract it and display it verbatim now — before any tutorial text. The block is already formatted correctly (fenced code block wrapped in `---` dividers); reproduce it as-is.
- If no such block is present (e.g., passing fast-check run), skip this step entirely — show nothing.
Only after this step (or immediately if no block) proceed to print the phase summary below.

If `$TUTORIAL_LANGUAGE = java`:
```
=== PROPERTY IMPLEMENTED ===

One property is now active and jqwik has exercised it across many generated
inputs. If no counterexample was found, the implementation satisfies this
property. If a counterexample was found, the shrunk input reveals a real bug.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== PROPERTY IMPLEMENTED ===

One property is now active and fast-check has exercised it across many generated
inputs. If no counterexample was found, the implementation satisfies this
property. If a counterexample was found, the shrunk input reveals a real bug.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "First property implemented. How would you like to continue?",
    "header": "Implement Properties",
    "multiSelect": false,
    "options": [
      { "label": "Implement the next property", "description": "Activate and implement one more property." },
      { "label": "That is enough — show me the debrief", "description": "I understand the flow. Jump to the debrief." }
    ]
  }]
}
```

On "Implement the next property": repeat Safety Net Step 3 for the next property.

On "That is enough — show me the debrief": continue to Safety Net Debrief.

---

### Safety Net Debrief

If `$TUTORIAL_LANGUAGE = java`:

Print:

```
=== PBT SAFETY NET DEBRIEF ════════════════════════════════════════════════

You have just run the PBT Safety Net workflow. Here is what each phase did
and why it matters:

TDD CYCLE — Why it matters:
  TDD drove the design and produced a working implementation with a clear
  interface. Example-based tests document specific behaviours: add(1, 2) = 3.
  They are fast to write, easy to read, and great for driving design decisions.
  But they only cover what you thought to test.

FIND PROPERTIES — Why it matters:
  The find-properties agent analyses your implementation and identifies universal
  statements — things that must be true for ALL valid inputs, regardless of
  specific values. For a calculator's add method, commutativity is one such
  property: add(a, b) = add(b, a) for every pair of integers. No finite set
  of examples can prove this; a property can.

IMPLEMENT PROPERTIES — Why it matters:
  Each property unleashes jqwik to generate thousands of inputs automatically.
  You do not need to think of edge cases — jqwik finds them. When it finds a
  counterexample, it shrinks it to the smallest possible failing input. That
  minimal case is a gift: it tells you precisely where your assumption breaks.
  A counterexample found here is a bug caught before it reaches production.

HOW TDD AND PBT COMPLEMENT EACH OTHER:
  TDD (examples)   → "add(1, 2) returns 3"       — specific, fast, design-driving
  PBT (properties) → "add(a, b) = add(b, a)"      — universal, exhaustive, bug-finding
  Together they form a complete verification strategy:
    - TDD shapes the design and documents intent
    - PBT hardens the implementation against the unexpected

THE SAFETY NET METAPHOR:
  Your TDD tests are a trampoline — they let you bounce back when you break
  something specific. Your PBT properties are a safety net — stretched wide
  beneath the trampoline, catching everything that slips through.
```

If `$TUTORIAL_LANGUAGE = typescript`:

Print:

```
=== PBT SAFETY NET DEBRIEF ════════════════════════════════════════════════

You have just run the PBT Safety Net workflow. Here is what each phase did
and why it matters:

TDD CYCLE — Why it matters:
  TDD drove the design and produced a working implementation with a clear
  interface. Example-based tests document specific behaviours: add(1, 2) = 3.
  They are fast to write, easy to read, and great for driving design decisions.
  But they only cover what you thought to test.

FIND PROPERTIES — Why it matters:
  The find-properties agent analyses your implementation and identifies universal
  statements — things that must be true for ALL valid inputs, regardless of
  specific values. For a calculator's add function, commutativity is one such
  property: add(a, b) = add(b, a) for every pair of numbers. No finite set
  of examples can prove this; a property can.

IMPLEMENT PROPERTIES — Why it matters:
  Each property unleashes fast-check to generate hundreds of inputs automatically.
  You do not need to think of edge cases — fast-check finds them. When it finds a
  counterexample, it shrinks it to the smallest possible failing input. That
  minimal case is a gift: it tells you precisely where your assumption breaks.
  A counterexample found here is a bug caught before it reaches production.

HOW TDD AND PBT COMPLEMENT EACH OTHER:
  TDD (examples)   → "add(1, 2) returns 3"       — specific, fast, design-driving
  PBT (properties) → "add(a, b) = add(b, a)"      — universal, exhaustive, bug-finding
  Together they form a complete verification strategy:
    - TDD shapes the design and documents intent
    - PBT hardens the implementation against the unexpected

THE SAFETY NET METAPHOR:
  Your TDD tests are a trampoline — they let you bounce back when you break
  something specific. Your PBT properties are a safety net — stretched wide
  beneath the trampoline, catching everything that slips through.
```

Continue to **Handoff**.

---

## Property-First Development Flow

### PFD Step 1 — Property List

Explain based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── Property-First: Step 1 — Property List ───────────────────────────────

In Property-First Development, properties drive the implementation from the
start — there are no example-based tests at all. We begin by identifying
what must be universally true about Calculator.add(int a, int b), then we
make those properties fail and pass one at a time.

The question is not "what does add(1, 2) return?" but "what holds for
ALL pairs of integers?"

[launching property-list agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── Property-First: Step 1 — Property List ───────────────────────────────

In Property-First Development, properties drive the implementation from the
start — there are no example-based tests at all. We begin by identifying
what must be universally true about Calculator.add(a, b), then we make
those properties fail and pass one at a time.

The question is not "what does add(1, 2) return?" but "what holds for
ALL pairs of numbers?"

[launching property-list agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `property-list` agent with:
```
Language: java
Feature: Calculator — add two integers
Properties file: src/test/java/CalculatorProperties.java
Implementation file: src/main/java/Calculator.java
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `property-list` agent with:
```
Language: typescript
Feature: Calculator — add two numbers
Properties file: src/Calculator.properties.test.ts
Implementation file: src/Calculator.ts
```

After the agent completes:

If `$TUTORIAL_LANGUAGE = java`:
```
=== PROPERTY LIST COMPLETE ===

The agent has created CalculatorProperties.java with @Disabled("todo")
placeholders. All properties are planned but none are active yet.

Next: we activate one property (Property Red phase) to drive the first
piece of implementation.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== PROPERTY LIST COMPLETE ===

The agent has created Calculator.properties.test.ts with test.todo(...)
placeholders. All properties are planned but none are active yet.

Next: we activate one property (Property Red phase) to drive the first
piece of implementation.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Property list created. Ready to start the Property Red phase?",
    "header": "Property List → Property Red",
    "multiSelect": false,
    "options": [
      { "label": "Start Property Red phase", "description": "Activate the first property and make it fail." },
      { "label": "Review the property list first", "description": "I want to read the properties before we proceed." }
    ]
  }]
}
```

On "Review the property list first": print the contents of the properties file
(`src/test/java/CalculatorProperties.java` for Java, `src/Calculator.properties.test.ts` for TypeScript)
and re-ask the checkpoint question.

On "Start Property Red phase": continue to PFD Step 2.

---

### PFD Step 2 — Property Red Phase

Explain based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── Property-First: Step 2 — Property Red ────────────────────────────────

We activate exactly one @Disabled("todo") property. The agent writes the
full property body (generators + assertions), then predicts how jqwik will
fail. Unlike TDD Red, jqwik does not report a specific wrong value — it
reports a COUNTEREXAMPLE: the smallest generated input for which the property
does not hold.

[launching property-red agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── Property-First: Step 2 — Property Red ────────────────────────────────

We activate exactly one test.todo(...) property. The agent writes the
full property body (generators + assertions), then predicts how fast-check will
fail. Unlike TDD Red, fast-check does not report a specific wrong value — it
reports a COUNTEREXAMPLE: the smallest generated input for which the property
does not hold.

[launching property-red agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `property-red` agent with:
```
Language: java
Properties file: src/test/java/CalculatorProperties.java
Activate property: next @Disabled property
Current state: 0 properties passing
Implementation file: src/main/java/Calculator.java
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `property-red` agent with:
```
Language: typescript
Properties file: src/Calculator.properties.test.ts
Activate property: next test.todo property
Current state: 0 properties passing
Implementation file: src/Calculator.ts
```

After the agent completes and reports Red phase complete, inspect the agent result for a framework output block:
- If the agent result contains a `---`-delimited block (jqwik statistics block or fast-check failure diagnostic), extract it and display it verbatim now — before any tutorial text. The block is already formatted correctly (fenced code block wrapped in `---` dividers); reproduce it as-is.
- If no such block is present (e.g., passing fast-check run), skip this step entirely — show nothing.
Only after this step (or immediately if no block) proceed to print the phase summary below.

If `$TUTORIAL_LANGUAGE = java`:
```
=== PROPERTY RED PHASE COMPLETE ===

One property is now active and failing. jqwik found a counterexample and
shrunk it to the minimal failing input. That shrunk example is the key:
it shows you exactly what the implementation must handle.

Unlike TDD Red, the failure is not "expected 3 but got 0" — it is a generated
input that broke your assumption. This is how PBT pushes the implementation
toward correctness across the full input space, not just your test cases.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== PROPERTY RED PHASE COMPLETE ===

One property is now active and failing. fast-check found a counterexample and
shrunk it to the minimal failing input. That shrunk example is the key:
it shows you exactly what the implementation must handle.

Unlike TDD Red, the failure is not "expected 3 but got 0" — it is a generated
input that broke your assumption. This is how PBT pushes the implementation
toward correctness across the full input space, not just your test cases.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Property Red phase complete. Ready to implement the minimal code (Property Green)?",
    "header": "Property Red → Property Green",
    "multiSelect": false,
    "options": [
      { "label": "Proceed to Property Green", "description": "Implement the minimal code to satisfy the property for ALL inputs." },
      { "label": "Explain the counterexample first", "description": "I want to understand the shrunk counterexample before proceeding." }
    ]
  }]
}
```

On "Explain the counterexample first": ask the agent to explain the shrunk
counterexample and why it demonstrates the property is violated, then
re-ask the checkpoint question.

On "Proceed to Property Green": continue to PFD Step 3.

---

### PFD Step 3 — Property Green Phase

Explain based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:
```
── Property-First: Step 3 — Property Green ──────────────────────────────

We implement the minimal code to make the property pass for ALL generated
inputs. This is the key difference from TDD Green:

  TDD Green:      a hardcoded return value is acceptable for one specific test
  PBT Green:      hardcoding is NOT acceptable — the implementation must
                  generalize across the full input space that jqwik explores

This constraint forces a more general solution earlier, but only as general
as the current property demands — not as general as future properties.

[launching property-green agent]
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
── Property-First: Step 3 — Property Green ──────────────────────────────

We implement the minimal code to make the property pass for ALL generated
inputs. This is the key difference from TDD Green:

  TDD Green:      a hardcoded return value is acceptable for one specific test
  PBT Green:      hardcoding is NOT acceptable — the implementation must
                  generalize across the full input space that fast-check explores

This constraint forces a more general solution earlier, but only as general
as the current property demands — not as general as future properties.

[launching property-green agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `property-green` agent with:
```
Language: java
Properties file: src/test/java/CalculatorProperties.java
Failing property: (the property activated in Property Red phase)
Property asserts: (description from Property Red phase)
Counterexample: (shrunk input from Property Red phase)
Implementation file: src/main/java/Calculator.java
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `property-green` agent with:
```
Language: typescript
Properties file: src/Calculator.properties.test.ts
Failing property: (the property activated in Property Red phase)
Property asserts: (description from Property Red phase)
Counterexample: (shrunk input from Property Red phase)
Implementation file: src/Calculator.ts
```

After the agent completes and reports Green phase complete, inspect the agent result for a framework output block:
- If the agent result contains a `---`-delimited block (jqwik statistics block or fast-check failure diagnostic), extract it and display it verbatim now — before any tutorial text. The block is already formatted correctly (fenced code block wrapped in `---` dividers); reproduce it as-is.
- If no such block is present (e.g., passing fast-check run), skip this step entirely — show nothing.
Only after this step (or immediately if no block) proceed to print the phase summary below.

```
=== PROPERTY GREEN PHASE COMPLETE ===

The property now passes for all generated inputs. The implementation is
minimal but general — it satisfies the current property without anticipating
future ones.
```

Call `AskUserQuestion` with:
```json
{
  "questions": [{
    "question": "Property Green phase complete. Ready to refactor?",
    "header": "Property Green → Refactor",
    "multiSelect": false,
    "options": [
      { "label": "Proceed to Refactor", "description": "Improve code quality while keeping the property green." },
      { "label": "Skip Refactor for now", "description": "I understand the cycle — jump to the debrief." }
    ]
  }]
}
```

On "Skip Refactor for now": jump to PFD Debrief.

On "Proceed to Refactor": continue to PFD Step 4.

---

### PFD Step 4 — Refactor Phase

Explain:

```
── Property-First: Step 4 — Refactor ────────────────────────────────────

The Refactor phase is identical to TDD Refactor — improve code quality while
keeping all properties green. The agent evaluates naming first, applies the
Four Rules of Simple Design, and calculates APP mass before and after.

[launching refactor agent]
```

If `$TUTORIAL_LANGUAGE = java`, call the `refactor` agent with:
```
Language: java
Test file: src/test/java/CalculatorProperties.java
Implementation file: src/main/java/Calculator.java
Passing tests: (current count from Property Green phase)
Recent Green phase: Implemented Calculator.add(int a, int b) to satisfy (property name)

Refactor the implementation while keeping all properties green.
```

If `$TUTORIAL_LANGUAGE = typescript`, call the `refactor` agent with:
```
Language: typescript
Test file: src/Calculator.properties.test.ts
Implementation file: src/Calculator.ts
Passing tests: (current count from Property Green phase)
Recent Green phase: Implemented Calculator.add(a, b) to satisfy (property name)

Refactor the implementation while keeping all properties green.
```

After the agent completes and reports Refactor phase complete:

If `$TUTORIAL_LANGUAGE = java`:
```
=== REFACTOR PHASE COMPLETE ===

One full Property Red → Property Green → Refactor cycle is done!

If there are remaining @Disabled("todo") properties, you would now loop back
to Property Red and activate the next one.
```

If `$TUTORIAL_LANGUAGE = typescript`:
```
=== REFACTOR PHASE COMPLETE ===

One full Property Red → Property Green → Refactor cycle is done!

If there are remaining test.todo(...) properties, you would now loop back
to Property Red and activate the next one.
```

Continue to PFD Debrief.

---

### PFD Debrief

If `$TUTORIAL_LANGUAGE = java`:

Print:

```
=== PROPERTY-FIRST DEVELOPMENT DEBRIEF ════════════════════════════════════

You just completed one Property Red → Property Green → Refactor cycle.
Here is what each phase did and why it matters:

PROPERTY LIST — Why it matters:
  Before any implementation, you identified what must universally hold.
  This shifts your thinking from "what should this return for input X?"
  to "what is invariantly true about this function across ALL inputs?"
  That shift produces a fundamentally different — and often deeper —
  understanding of the problem domain.

PROPERTY RED — Why it matters:
  Activating a property with no implementation forces jqwik to find a
  counterexample immediately. The shrunk counterexample is not just a
  test failure; it is a minimal proof that the property is violated. It
  guides the implementation more precisely than any example could.

PROPERTY GREEN — Why it matters:
  The no-hardcoding constraint is the core discipline of PBT Green.
  You cannot return a fixed value because jqwik will immediately try
  other inputs. You must reason about the general case from the start.
  This constraint accelerates convergence to a correct implementation.

REFACTOR — Why it matters:
  Same as in TDD: the passing properties form a safety net that lets
  you restructure without fear. Property coverage is often broader than
  example coverage, so refactoring under properties gives you stronger
  guarantees that you have not broken anything subtle.

PROPERTY-FIRST vs TDD:
  TDD:              examples drive design, properties harden later
  Property-First:   properties drive design from the start

  Neither is strictly superior. Property-First forces generality early
  but can be harder to start (what is the first property?). TDD produces
  early momentum but may miss edge cases without a subsequent PBT pass.

  For simple arithmetic and pure functions: Property-First works beautifully.
  For complex domain logic with many invariants: TDD first, then PBT Safety Net.
```

If `$TUTORIAL_LANGUAGE = typescript`:

Print:

```
=== PROPERTY-FIRST DEVELOPMENT DEBRIEF ════════════════════════════════════

You just completed one Property Red → Property Green → Refactor cycle.
Here is what each phase did and why it matters:

PROPERTY LIST — Why it matters:
  Before any implementation, you identified what must universally hold.
  This shifts your thinking from "what should this return for input X?"
  to "what is invariantly true about this function across ALL inputs?"
  That shift produces a fundamentally different — and often deeper —
  understanding of the problem domain.

PROPERTY RED — Why it matters:
  Activating a property with no implementation forces fast-check to find a
  counterexample immediately. The shrunk counterexample is not just a
  test failure; it is a minimal proof that the property is violated. It
  guides the implementation more precisely than any example could.

PROPERTY GREEN — Why it matters:
  The no-hardcoding constraint is the core discipline of PBT Green.
  You cannot return a fixed value because fast-check will immediately try
  other inputs. You must reason about the general case from the start.
  This constraint accelerates convergence to a correct implementation.

REFACTOR — Why it matters:
  Same as in TDD: the passing properties form a safety net that lets
  you restructure without fear. Property coverage is often broader than
  example coverage, so refactoring under properties gives you stronger
  guarantees that you have not broken anything subtle.

PROPERTY-FIRST vs TDD:
  TDD:              examples drive design, properties harden later
  Property-First:   properties drive design from the start

  Neither is strictly superior. Property-First forces generality early
  but can be harder to start (what is the first property?). TDD produces
  early momentum but may miss edge cases without a subsequent PBT pass.

  For simple arithmetic and pure functions: Property-First works beautifully.
  For complex domain logic with many invariants: TDD first, then PBT Safety Net.
```

Continue to **Handoff**.

---

## Handoff

Print the appropriate message based on `$TUTORIAL_LANGUAGE`:

If `$TUTORIAL_LANGUAGE = java`:

```
=== TUTORIAL COMPLETE ════════════════════════════════════════════════════

You have completed the hands-on tutorial (Java + jqwik). Here is how to
carry what you learned into your own project or kata:

YOUR NEXT STEP — choose one:

  If you have a kata or feature to implement:
    Run: /tdd-pbt:test-list
    Tell it the feature name and the file paths.
    It will create the test list and guide you into the Red phase.
    (It will ask for your language choice and write .tdd-pbt/config.yml)

  If you want to add PBT to an existing implementation:
    Run: /tdd-pbt:find-properties
    Point it at your implementation and existing tests.
    It will identify properties and create the Properties file.

  If you want to try Property-First Development on a real feature:
    Run: /tdd-pbt:property-list
    Describe the feature. It will list properties and start the cycle.

KEY THINGS TO REMEMBER:

  1. Red → Green → Refactor. Every time. Never skip Refactor.
     Skipping Refactor feels efficient; it is not. Technical debt
     accumulates precisely where the cycle is skipped.

  2. One test (or property) at a time. Activating multiple tests at once
     defeats the purpose: you lose the signal of which test drove which
     implementation decision.

  3. Make a prediction before running. The Guessing Game is not ceremony.
     A wrong prediction is a gap in your understanding of the code.

  4. TDD and PBT are complementary, not competing.
     TDD: specific examples, fast, design-driving.
     PBT: universal properties, exhaustive, bug-finding.
     Use both.

  5. Discomfort is a signal you are doing it right.
     Hardcoded returns feel wrong. Baby steps feel slow. Resist the urge
     to jump ahead. The constraint is the discipline.

Good luck — and enjoy the rhythm.
```

If `$TUTORIAL_LANGUAGE = typescript`:

```
=== TUTORIAL COMPLETE ════════════════════════════════════════════════════

You have completed the hands-on tutorial (TypeScript + fast-check + Vitest).
Here is how to carry what you learned into your own project or kata:

YOUR NEXT STEP — choose one:

  If you have a kata or feature to implement:
    Run: /tdd-pbt:test-list
    Tell it the feature name and the file paths.
    It will create the test list and guide you into the Red phase.
    (It will ask for your language choice and write .tdd-pbt/config.yml)

  If you want to add PBT to an existing implementation:
    Run: /tdd-pbt:find-properties
    Point it at your implementation and existing tests.
    It will identify properties and create the Properties file.

  If you want to try Property-First Development on a real feature:
    Run: /tdd-pbt:property-list
    Describe the feature. It will list properties and start the cycle.

KEY THINGS TO REMEMBER:

  1. Red → Green → Refactor. Every time. Never skip Refactor.
     Skipping Refactor feels efficient; it is not. Technical debt
     accumulates precisely where the cycle is skipped.

  2. One test (or property) at a time. Activating multiple tests at once
     defeats the purpose: you lose the signal of which test drove which
     implementation decision.

  3. Make a prediction before running. The Guessing Game is not ceremony.
     A wrong prediction is a gap in your understanding of the code.

  4. TDD and PBT are complementary, not competing.
     TDD: specific examples, fast, design-driving.
     PBT: universal properties, exhaustive, bug-finding.
     Use both.

  5. Discomfort is a signal you are doing it right.
     Hardcoded returns feel wrong. Baby steps feel slow. Resist the urge
     to jump ahead. The constraint is the discipline.

Good luck — and enjoy the rhythm.
```

---

## What you must NOT do

- Must not skip a checkpoint or proceed to the next phase without waiting for
  the user's explicit response.
- Must not write test code or implementation code directly — always delegate to
  the appropriate agent.
- Must not reference external kata files or workshop repo content — the toy
  problem is entirely self-contained.
- Must not simulate agent invocations — every agent call (test-list, red, green,
  refactor, find-properties, implement-properties, property-list, property-red,
  property-green) must be a real Task invocation.
- Must not combine multiple phases into a single agent call (e.g., do NOT call
  the green agent and ask it to also refactor).
- Must not proceed past a failed prediction without stopping to explain the
  discrepancy to the user.
- Must not write `.tdd-pbt/config.yml` under any circumstances — the tutorial
  stores the language choice in `$TUTORIAL_LANGUAGE` for the session only.
- Must not pass language context to agents without the `Language: <java|typescript>`
  field in the agent call prompt.
