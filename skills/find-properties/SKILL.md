---
name: find-properties
description: Use after TDD to analyze the implementation and identify properties for safety-net testing. Triggers on phrases like "find properties", "PBT safety net", "harden the implementation", "what properties does this have". Creates a *Properties.java (Java) or *.properties.test.ts (TypeScript) file with placeholder properties. Stops and waits for user approval before proceeding to implement-properties.
---

# /tdd-pbt:find-properties — PBT Safety Net: Find Properties

`/tdd-pbt:find-properties` launches the `find-properties` agent to analyze an existing TDD implementation and discover properties for property-based safety-net testing.

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
   - Implementation file path (the production code to analyze)
   - Existing TDD test file path (to understand tested behaviors)
   - Target properties file path:
     - Java: `src/test/java/<package>/<ClassName>Properties.java`
     - TypeScript: `src/<ClassName>.properties.test.ts`

2. Call the `find-properties` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Implementation file: <path to production code>
   TDD test file: <path to existing test file>
   Properties file: <path for new properties file>
   ```

3. The agent will:
   - Read the implementation and test file
   - Systematically check all property categories (invariants, roundtrips, idempotence, symmetry, hard-to-verify, test oracle)
   - Java: Create a `*Properties.java` file with `@Disabled("todo")` placeholders
   - TypeScript: Create a `*.properties.test.ts` file with `test.todo(...)` placeholders
   - Explain each discovered property and why it matters
   - Stop and ask for approval before implementing

4. After the agent completes and reports properties found, wait for the user to confirm before proceeding to `/tdd-pbt:implement-properties`.

## What you must NOT do

- Must not implement property bodies — only signatures with `@Disabled("todo")` (Java) or `test.todo(...)` (TypeScript).
- Must not modify the existing implementation or TDD test files.
- Must not write weak properties ("result is not null").
- Must not reimplement the algorithm inside a property assertion.
- Must not proceed to implement-properties without explicit user approval.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
