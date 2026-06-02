---
name: test-list
description: Use when starting TDD for a new feature or function. Creates a comprehensive test list using @Disabled("todo") (Java) or test.todo(...) (TypeScript) placeholders for base functionality only, ordered from simplest to most complex. Triggers on phrases like "start TDD", "create test list", "plan tests for", "I want to implement X using TDD", "what tests should I write". Does not write implementation code — only plans the test cases.
---

# /tdd-pbt:test-list — TDD Test List Phase

`/tdd-pbt:test-list` launches the `test-list` agent to create a structured test list before any implementation begins.

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

1. Collect the feature description and file paths from the user's invocation or context:
   - Feature/function to implement
   - Target test file path
     - Java: `src/test/java/<package>/<ClassName>Test.java`
     - TypeScript: `src/<ClassName>.test.ts`
   - Target implementation file path
     - Java: `src/main/java/<package>/<ClassName>.java`
     - TypeScript: `src/<ClassName>.ts`
   - Any constraints or requirements

2. Call the `test-list` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Feature: <feature description>
   Test file: <test file path>
   Implementation file: <implementation file path>
   Requirements: <requirements or constraints>
   ```

3. The agent will produce a test file with `@Disabled("todo")` (Java) or `test.todo(...)` (TypeScript) placeholders and a summary of the test list.

4. After the agent completes, present the result to the user and prompt them to run `/tdd-pbt:red` to start the Red phase with the first test.

## What you must NOT do

- Must not write test code directly — delegate entirely to the `test-list` agent.
- Must not write implementation code — the test list phase produces no production code.
- Must not activate any tests — all tests in the list use `@Disabled("todo")` (Java) or `test.todo(...)` (TypeScript).
- Must not skip ahead to Red phase automatically — wait for the user to confirm the test list first.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
