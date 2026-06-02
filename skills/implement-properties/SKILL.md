---
name: implement-properties
description: Use after find-properties to implement one placeholder property at a time and analyze results. Triggers on phrases like "implement the next property", "let's implement properties", "next property please". Implements exactly one property, runs tests, analyzes any counterexample. Stops and waits for user approval before the next property.
---

# /tdd-pbt:implement-properties — PBT Safety Net: Implement Properties

`/tdd-pbt:implement-properties` launches the `implement-properties` agent to implement one placeholder property at a time and analyze the results.

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
   - Properties file path:
     - Java: the `*Properties.java` file with `@Disabled` placeholders
     - TypeScript: the `*.properties.test.ts` file with `test.todo(...)` placeholders
   - Implementation file path (the production code under test)
   - Which property to implement (name or "next one" meaning the first remaining)

2. Call the `implement-properties` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Properties file: <path to properties file>
   Implementation file: <path to production code>
   Implement property: "<propertyMethodName>" (or "next placeholder property")
   ```

3. The agent will:
   - Select exactly one placeholder property
   - Java: Remove `@Disabled("todo")` and write the property body with `@ForAll` generators and AssertJ assertions
   - TypeScript: Replace `test.todo(...)` with a full `it('...', () => { fc.assert(fc.property(...)) })` body
   - Java: Run `mvn test` and analyze the result
   - TypeScript: Run `npx vitest run` and analyze the result
   - If a counterexample is found, explain the shrunk input and its implications
   - Stop and ask for approval before the next property

4. After the agent completes and reports the result, wait for the user to confirm before proceeding to the next property.

## What you must NOT do

- Must not implement more than one property at a time.
- Must not modify the production implementation.
- Must not write properties that reimplement the algorithm.
- Must not ignore counterexamples — always analyze the shrunk input.
- Must not proceed to the next property without explicit user approval.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
