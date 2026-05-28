---
name: red
description: Use when activating the next test from the TDD test list. Guides through the Red phase — converting one @Disabled("todo") test to an executable failing test, making predictions before running, and verifying it fails for the right reason. Triggers on phrases like "start Red phase", "activate the next test", "let's go red", "next test", "make a test fail". Always leaves all other tests as @Disabled("todo"). Stops and waits for user approval before proceeding to Green.
---

# /tdd-pbt:red — TDD Red Phase

`/tdd-pbt:red` launches the `red` agent to activate exactly one test from the test list and drive it to a failing state.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Test file path
   - Which `@Disabled("todo")` test to activate (name or line number, or "next one" meaning the first remaining)
   - Current number of passing tests
   - Implementation file path

2. Call the `red` agent with all collected context as the prompt. Include:
   ```
   Test file: <test file path>
   Activate test: "<testMethodName>" (or "next @Disabled test")
   Current state: <N> tests passing
   Implementation file: <implementation file path>
   ```

3. The agent will:
   - Activate exactly one test (remove its `@Disabled("todo")`)
   - Make explicit predictions before each `mvn test` run (Guessing Game)
   - Verify compilation error first, then runtime/assertion error
   - Stop and ask for approval before Green phase

4. After the agent completes and reports "Red phase complete", wait for the user to confirm before proceeding.

## What you must NOT do

- Must not activate more than one test at a time.
- Must not write implementation code — Red phase produces no production code beyond an empty class/method stub.
- Must not proceed to Green phase without explicit user approval.
- Must not skip the prediction step (Guessing Game).
- Must not continue after a failed prediction without stopping to explain.
