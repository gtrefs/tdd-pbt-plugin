---
name: green
description: Use after the Red phase to implement the minimal code that makes the failing test pass. Triggers on phrases like "make the test pass", "Green phase", "implement the minimal solution", "yes proceed to Green", "let's go green". Hardcoded return values are acceptable and encouraged for early tests. Stops and waits for user approval before proceeding to Refactor.
---

# /tdd-pbt:green — TDD Green Phase

`/tdd-pbt:green` launches the `green` agent to implement the minimal production code that makes the currently failing test pass.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Test file path
   - Name of the failing test and its expected behavior
   - Current error message (from the Red phase run)
   - Implementation file path

2. Call the `green` agent with all collected context as the prompt. Include:
   ```
   Test file: <test file path>
   Failing test: "<testMethodName>"
   Expected: <method>(<args>) returns <value>
   Current error: <paste error message>
   Implementation file: <implementation file path>
   ```

3. The agent will:
   - Write the minimal code necessary to pass the failing test
   - Use hardcoded values or the simplest logic that works
   - Run `mvn test` and verify all tests pass
   - Stop and ask for approval before Refactor phase

4. After the agent completes and reports "Green phase complete", wait for the user to confirm before proceeding.

## What you must NOT do

- Must not implement features for future tests.
- Must not refactor — that is strictly the Refactor agent's responsibility.
- Must not proceed to Refactor phase without explicit user approval.
- Must not write complex logic when a simple hardcoded value would suffice.
- Must not combine the Green and Refactor phases into a single agent call.
