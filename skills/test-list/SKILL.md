---
name: test-list
description: Use when starting TDD for a new feature or function. Creates a comprehensive test list using @Disabled("todo") placeholders for base functionality only, ordered from simplest to most complex. Triggers on phrases like "start TDD", "create test list", "plan tests for", "I want to implement X using TDD", "what tests should I write". Does not write implementation code — only plans the test cases.
---

# /tdd-pbt:test-list — TDD Test List Phase

`/tdd-pbt:test-list` launches the `test-list` agent to create a structured test list before any implementation begins.

## What you do

1. Collect the feature description and file paths from the user's invocation or context:
   - Feature/function to implement
   - Target test file path (e.g., `src/test/java/<package>/<ClassName>Test.java`)
   - Target implementation file path (e.g., `src/main/java/<package>/<ClassName>.java`)
   - Any constraints or requirements

2. Call the `test-list` agent with all collected context as the prompt. Include:
   ```
   Feature: <feature description>
   Test file: <test file path>
   Implementation file: <implementation file path>
   Requirements: <requirements or constraints>
   ```

3. The agent will produce a test file with `@Disabled("todo")` placeholders and a summary of the test list.

4. After the agent completes, present the result to the user and prompt them to run `/tdd-pbt:red` to start the Red phase with the first test.

## What you must NOT do

- Must not write test code directly — delegate entirely to the `test-list` agent.
- Must not write implementation code — the test list phase produces no production code.
- Must not activate any tests — all tests in the list use `@Disabled("todo")`.
- Must not skip ahead to Red phase automatically — wait for the user to confirm the test list first.
