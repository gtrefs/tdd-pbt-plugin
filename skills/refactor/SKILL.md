---
name: refactor
description: Use after the Green phase to improve code quality while keeping all tests green. Applies Kent Beck's Four Rules of Simple Design and Micah Martin's Absolute Priority Premise (APP) mass calculation. Triggers on phrases like "refactor", "Refactor phase", "improve the code", "yes proceed to Refactor", "clean up the code". Always attempts at least one refactoring — evaluates naming first, then duplication, then simplification. Stops and waits for user approval before moving to the next test.
---

# /tdd-pbt:refactor — TDD Refactor Phase

`/tdd-pbt:refactor` launches the `refactor` agent to improve code quality after the Green phase, applying Simple Design Rules and APP mass calculations.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Test file path
   - Implementation file path
   - Current number of passing tests
   - Brief description of what was changed in the Green phase

2. Call the `refactor` agent with all collected context as the prompt. Include:
   ```
   Test file: <test file path>
   Implementation file: <implementation file path>
   Passing tests: <N>
   Recent Green phase: <brief description of the change made>

   Refactor the implementation while keeping all tests green.
   ```

3. The agent will:
   - Evaluate naming first (Rule 2 — Reveals Intent)
   - Calculate APP mass before any changes
   - Apply the Four Rules of Simple Design in priority order
   - Make one improvement at a time, running `mvn test` after each
   - Recalculate APP mass after changes
   - Document all decisions (improvements made or why none were possible)
   - Stop and ask for approval before the next test

4. After the agent completes and reports "Refactor phase complete", wait for the user to confirm before looping back to `/tdd-pbt:red` for the next test.

## What you must NOT do

- Must not skip the refactoring attempt — at least one improvement must be evaluated.
- Must not break passing tests during refactoring.
- Must not implement new features or add logic not demanded by existing tests.
- Must not proceed to the next test without explicit user approval.
- Must not sacrifice code clarity for a lower APP mass score.
