# Test-Driven Development (TDD) Rules

## CRITICAL: Agent Usage is MANDATORY

**YOU MUST USE THE SPECIALIZED TDD AGENTS FOR EVERY TDD TASK.**

Do NOT perform TDD phases manually. The agents enforce discipline and prevent common mistakes.

### Before Starting Any TDD Work - Complete This Checklist:

- [ ] Have I been asked to implement something using TDD?
- [ ] Am I about to write tests or implementation code?
- [ ] **STOP** - Use the Task tool to launch the appropriate TDD agent
- [ ] NEVER write tests or code directly - ALWAYS use agents

### Which Agent to Use:

| Phase | Agent Name | Use Task Tool With |
|-------|-----------|-------------------|
| Test List | `test-list` | `subagent_type: "test-list"` |
| Red Phase | `red` | `subagent_type: "red"` |
| Green Phase | `green` | `subagent_type: "green"` |
| Refactor Phase | `refactor` | `subagent_type: "refactor"` |

**If you find yourself writing test code or implementation code without launching an agent first, you are doing it WRONG.**

## Overview

This plugin enforces strict Test-Driven Development practices using the Red-Green-Refactor cycle with human-in-the-loop checkpoints.

## TDD Workflow

**MANDATORY: Use the specialized TDD agents for each phase of the cycle:**

### 1. Test List Phase
**LAUNCH AGENT**: Use `Task` tool with `subagent_type: "test-list"`

**Required prompt context:**
- Feature/function to implement
- Target file paths (test file + implementation file)
- Any constraints or requirements from the user

**Example Task call:**
```
Task({
  subagent_type: "test-list",
  prompt: `
    Feature: <describe feature>
    Test file: src/test/java/<package>/<ClassName>Test.java
    Implementation file: src/main/java/<package>/<ClassName>.java
    Requirements: <describe requirements>
  `
})
```

The agent will create a comprehensive test list using `@Disabled("todo")` for BASE FUNCTIONALITY ONLY:
- Focus on core behavior, not advanced features
- Order tests from simple to complex
- No implementation yet

**DO NOT** write the test list yourself - let the agent do it.

### 2. Red Phase
**LAUNCH AGENT**: Use `Task` tool with `subagent_type: "red"`

**Required prompt context:**
- Test file path
- Which `@Disabled("todo")` test to activate (name or line number)
- Current state (number of passing tests)
- Implementation file path

**Example Task call:**
```
Task({
  subagent_type: "red",
  prompt: `
    Test file: src/test/java/<package>/<ClassName>Test.java
    Activate test: "<testMethodName>" (line <N>)
    Current state: <N> tests passing
    Implementation file: src/main/java/<package>/<ClassName>.java
  `
})
```

The agent will activate exactly ONE test and make it fail:
- Convert one `@Disabled("todo")` to an executable test
- Make explicit predictions (Guessing Game)
- Verify compilation error, then runtime error
- Stop and wait for approval before Green phase

**DO NOT** write test code yourself - let the agent do it.

### 3. Green Phase
**LAUNCH AGENT**: Use `Task` tool with `subagent_type: "green"`

**Required prompt context:**
- Test file path
- Failing test name and expected behavior
- Current error message
- Implementation file path

**Example Task call:**
```
Task({
  subagent_type: "green",
  prompt: `
    Test file: src/test/java/<package>/<ClassName>Test.java
    Failing test: "<testMethodName>"
    Expected: <method>(<args>) returns <value>
    Current error: <paste error message>
    Implementation file: src/main/java/<package>/<ClassName>.java
  `
})
```

The agent will implement minimal code to make the test pass:
- Use the simplest possible solution
- Hardcoded returns are acceptable early on
- No features for future tests
- Stop and wait for approval before Refactor phase

**DO NOT** write implementation code yourself - let the agent do it.

### 4. Refactor Phase
**LAUNCH AGENT**: Use `Task` tool with `subagent_type: "refactor"`

**CRITICAL: Refactor MUST be a separate agent call.** The orchestrating agent must NEVER combine Green and Refactor into one Task. After Green phase completes, launch a NEW Task with `subagent_type: "refactor"` — do NOT ask the Green agent to refactor. Each phase = one dedicated agent invocation.

**Required prompt context:**
- Test file path
- Implementation file path
- Current number of passing tests
- Recent changes made in Green phase

**Example Task call:**
```
Task({
  subagent_type: "refactor",
  prompt: `
    Test file: src/test/java/<package>/<ClassName>Test.java
    Implementation file: src/main/java/<package>/<ClassName>.java
    Passing tests: <N>
    Recent Green phase: <brief description of what was changed>

    Refactor the implementation while keeping all tests green.
  `
})
```

The agent will improve code while keeping tests green:
- **MUST attempt at least one refactoring**
- Evaluate naming FIRST
- Apply Four Rules of Simple Design (priority order)
- Calculate APP (Absolute Priority Premise) mass
- Document improvements or why none were possible
- Stop and wait for approval before next test

**DO NOT** refactor code yourself - let the agent do it.

### 5. Repeat
Return to step 2 (Red phase) for the next test in the list.

**Launch the `red` agent again - DO NOT proceed manually.**

### Autonomous Mode Does NOT Change the Cycle

When the user asks to "work autonomously" or "do it on your own", this means:
- **DO** run all phases without waiting for approval after each one
- **DO NOT** skip any phase — especially not Refactor
- **DO** call each phase agent separately: Task(red) → Task(green) → Task(refactor) — three distinct agent invocations per test
- The cycle **Red → Green → Refactor** is non-negotiable, regardless of how autonomously you operate
- "Autonomous" changes the **checkpoints**, not the **process**

## Core TDD Principles

### TDD Mindset
TDD practices will feel counterintuitive:
- **Hardcoded returns feel "too simple"** - This is correct!
- **The urge to implement ahead is strong** - Resist this
- **Minimal steps feel inefficient** - They actually accelerate development
- **Predictions feel unnecessary** - They build crucial understanding
- **Push through discomfort** - These feelings indicate you're following the discipline correctly

### Common TDD Failure Modes
Watch for these violations:
- **NOT USING TDD AGENTS** - The most critical failure mode!
- **SKIPPING REFACTOR PHASE** - "Autonomous" or "do it yourself" NEVER means skipping phases. The cycle is ALWAYS Red → Green → Refactor. Every. Single. Time. Even when the user says "work autonomously", that means "run all three phases without asking after each one" — NOT "skip Refactor and just do Red → Green."
- **COMBINING PHASES** - Refactor phase requires its OWN Task call with `subagent_type: "refactor"`. Never combine Green+Refactor into one agent invocation. The orchestrator must call the Refactor agent explicitly after each Green phase.
- Planning beyond base functionality
- Multiple active tests at once
- Implementing beyond what tests demand
- Skipping predictions
- Avoiding refactoring
- Premature abstraction
- Ignoring the uncomfortable
- Writing code directly instead of launching agents

### Why This Discipline Works
- **Baby steps reveal simpler solutions** - Implementing only what tests demand often uncovers simpler approaches
- **One-test-at-a-time prevents complexity** - Not thinking ahead eliminates unnecessary features
- **Predictions build confidence** - Explicit expectations create deeper understanding
- **Refactoring becomes natural** - Mandatory improvement attempts prevent technical debt
- **The process fights harmful instincts** - Programming instincts often lead to premature optimization

## Human-in-the-Loop

See `human-in-the-loop.md` for detailed checkpoint requirements.

**Key principle**: Stop after every phase (Red, Green, Refactor) and wait for explicit approval before continuing.

## Technical Setup

See `tdd_with_java_and_junit.md` for Java and JUnit configuration.

## Running Tests - CRITICAL

**TDD agents MUST use Maven goals from `pom.xml`**

### Correct Test Execution:
- `mvn test` - Run all tests

### NEVER use:
- `java -jar junit-platform-standalone.jar` - Don't run JUnit directly
- `mvn exec:java -Dexec.mainClass=...` - Don't invoke test runner manually
- Individual test class execution - Always use Maven goals

**Why**: Maven goals provide a consistent interface. Direct JUnit invocation skips centralized configuration.

## Remember

- **ALWAYS USE TDD AGENTS** - Never write tests or code directly during TDD
- **Discomfort is a signal you're doing it right** - TDD should feel constraining at first
- **Trust the process** - Simple steps compound into elegant solutions
- **Discipline over instinct** - Follow the rules even when they feel wrong
- **Agents enforce TDD discipline** - They prevent you from making common mistakes

## Self-Check Before Proceeding

Ask yourself before writing ANY code:

1. **Am I doing TDD right now?**
   - If YES: Have I launched the appropriate agent?
   - If NO agent launched: STOP and launch the agent first

2. **Am I about to write a test or implementation?**
   - If YES: Which phase am I in? Have I launched that agent?
   - If NO agent launched: STOP and launch the agent first

3. **Did the user ask me to use TDD or am I implementing a feature?**
   - If YES: Launch test-list agent to start
   - If unsure: Ask the user

**When in doubt, use the agents. They are there to help you follow the discipline correctly.**
