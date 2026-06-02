---
name: green
description: Use after the Red phase to implement the minimal code that makes the failing test pass. Triggers on phrases like "make the test pass", "Green phase", "implement the minimal solution", "yes proceed to Green", "let's go green". Hardcoded return values are acceptable and encouraged for early tests. Stops and waits for user approval before proceeding to Refactor.
---

# /tdd-pbt:green — TDD Green Phase

`/tdd-pbt:green` launches the `green` agent to implement the minimal production code that makes the currently failing test pass.

## Step 0 — Detect language

Check whether `.tdd-pbt/config.yml` exists in the current working directory.

If it exists: read the `language` field. Use it for all subsequent steps.

If it does not exist: ask the user:

```
AskUserQuestion:
  question: "Which language and PBT library will you use for this project?"
  header: "Language setup"
  options:
    - label: "Java + jqwik 1.9.3"
      description: "Java project using Maven, JUnit 5, and jqwik 1.9.3"
    - label: "TypeScript + fast-check + Vitest"
      description: "TypeScript project using Vitest and fast-check"
```

Then write `.tdd-pbt/config.yml` to the current working directory:
```yaml
language: java   # or typescript
```

Confirm: "Language set to <choice>. Config written to .tdd-pbt/config.yml."

<!-- Invariant: config is written at most once per project; if file already exists, do not overwrite it -->
<!-- Invariant: language field is always "java" or "typescript" — never any other value -->

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Test file path
   - Name of the failing test and its expected behavior
   - Current error message (from the Red phase run)
   - Implementation file path

2. Call the `green` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Test file: <test file path>
   Failing test: "<testMethodName>"
   Expected: <method>(<args>) returns <value>
   Current error: <paste error message>
   Implementation file: <implementation file path>
   ```

3. The agent will:
   - Write the minimal code necessary to pass the failing test
   - Use hardcoded values or the simplest logic that works
   - Java: Run `mvn test` and verify all tests pass
   - TypeScript: Run `npx vitest run` and verify all tests pass
   - Stop and ask for approval before Refactor phase

4. After the agent completes and reports "Green phase complete", wait for the user to confirm before proceeding.

## What you must NOT do

- Must not implement features for future tests.
- Must not refactor — that is strictly the Refactor agent's responsibility.
- Must not proceed to Refactor phase without explicit user approval.
- Must not write complex logic when a simple hardcoded value would suffice.
- Must not combine the Green and Refactor phases into a single agent call.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
