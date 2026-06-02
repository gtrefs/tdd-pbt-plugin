---
name: red
description: Use when activating the next test from the TDD test list. Guides through the Red phase — converting one @Disabled("todo") (Java) or test.todo(...) (TypeScript) test to an executable failing test, making predictions before running, and verifying it fails for the right reason. Triggers on phrases like "start Red phase", "activate the next test", "let's go red", "next test", "make a test fail". Always leaves all other tests as @Disabled("todo") / test.todo(...). Stops and waits for user approval before proceeding to Green.
---

# /tdd-pbt:red — TDD Red Phase

`/tdd-pbt:red` launches the `red` agent to activate exactly one test from the test list and drive it to a failing state.

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
   - Which placeholder test to activate (name or line number, or "next one"):
     - Java: `@Disabled("todo")`
     - TypeScript: `test.todo(...)`
   - Current number of passing tests
   - Implementation file path

2. Call the `red` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Test file: <test file path>
   Activate test: "<testMethodName>" (or "next @Disabled test" / "next test.todo")
   Current state: <N> tests passing
   Implementation file: <implementation file path>
   ```

3. The agent will:
   - Java: Activate exactly one test (remove its `@Disabled("todo")`)
   - TypeScript: Convert one `test.todo(...)` to an executable test body
   - Make explicit predictions before each test run (Guessing Game)
   - Java: Verify compilation error first, then runtime/assertion error; run with `mvn test`
   - TypeScript: Verify type error first (if applicable), then assertion error; run with `npx vitest run`
   - Stop and ask for approval before Green phase

4. After the agent completes and reports "Red phase complete", wait for the user to confirm before proceeding.

## What you must NOT do

- Must not activate more than one test at a time.
- Must not write implementation code — Red phase produces no production code beyond an empty class/method stub.
- Must not proceed to Green phase without explicit user approval.
- Must not skip the prediction step (Guessing Game).
- Must not continue after a failed prediction without stopping to explain.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
