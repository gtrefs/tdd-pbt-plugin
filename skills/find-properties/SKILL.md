---
name: find-properties
description: Use after TDD to analyze the implementation and identify properties for safety-net testing. Triggers on phrases like "find properties", "PBT safety net", "harden the implementation", "what properties does this have". Creates a *Properties.java file with @Disabled("todo") placeholders. Stops and waits for user approval before proceeding to implement-properties.
---

# /tdd-pbt:find-properties — PBT Safety Net: Find Properties

`/tdd-pbt:find-properties` launches the `find-properties` agent to analyze an existing TDD implementation and discover properties for property-based safety-net testing.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Implementation file path (the production code to analyze)
   - Existing TDD test file path (to understand tested behaviors)
   - Target properties file path (where to create `*Properties.java`)

2. Call the `find-properties` agent with all collected context as the prompt. Include:
   ```
   Implementation file: <path to production code>
   TDD test file: <path to existing test file>
   Properties file: <path for new *Properties.java>
   ```

3. The agent will:
   - Read the implementation and test file
   - Systematically check all property categories (invariants, roundtrips, idempotence, symmetry, hard-to-verify, test oracle)
   - Create a `*Properties.java` file with `@Disabled("todo")` placeholders
   - Explain each discovered property and why it matters
   - Stop and ask for approval before implementing

4. After the agent completes and reports properties found, wait for the user to confirm before proceeding to `/tdd-pbt:implement-properties`.

## What you must NOT do

- Must not implement property bodies — only signatures with `@Disabled("todo")`.
- Must not modify the existing implementation or TDD test files.
- Must not write weak properties ("result is not null").
- Must not reimplement the algorithm inside a property assertion.
- Must not proceed to implement-properties without explicit user approval.
