---
name: property-list
description: Use when starting Property-First Development to create a comprehensive property list. Triggers on phrases like "start property-first", "create property list", "identify properties for", "let's do PBT-first". Creates a properties file with placeholder properties ordered from simplest to most complex. Does not activate any property — that is the job of /tdd-pbt:property-red.
---

# /tdd-pbt:property-list — Property-First Development: Property List

`/tdd-pbt:property-list` launches the `property-list` agent to identify and list properties for a feature before any implementation begins. This is Step 1 of the Property-First Development cycle.

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
   - Feature description or requirements
   - Target properties file path:
     - Java: `src/test/java/<package>/<ClassName>Properties.java`
     - TypeScript: `src/<ClassName>.properties.test.ts`
   - Target implementation file path:
     - Java: `src/main/java/<package>/<ClassName>.java`
     - TypeScript: `src/<ClassName>.ts`

2. Call the `property-list` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Feature: <description of what to implement>
   Properties file: <path for new properties file>
   Implementation file: <path for production code>
   ```

3. The agent will:
   - Analyze the feature requirements
   - Systematically identify properties across all categories (invariants, roundtrips, idempotence, symmetry, hard-to-verify, test oracle)
   - Order properties from simplest to most complex
   - Java: Create a `*Properties.java` file with `@Disabled("todo")` placeholders
   - TypeScript: Create a `*.properties.test.ts` file with `test.todo(...)` placeholders
   - Present a summary of properties with categories and descriptions

4. After the agent presents the property list, the next step is `/tdd-pbt:property-red` to activate the first property.

## Property-First Development Cycle

```
/tdd-pbt:property-list  →  /tdd-pbt:property-red  →  /tdd-pbt:property-green  →  /tdd-pbt:refactor
                                    ↑_______________________________________________|
                                             (repeat for each property)
```

## What you must NOT do

- Must not implement property bodies — only placeholders (`@Disabled("todo")` for Java, `test.todo(...)` for TypeScript).
- Must not include advanced properties in the initial list — base functionality only.
- Must not activate any property — that is the job of `/tdd-pbt:property-red`.
- Must not think about implementation — focus on WHAT holds true, not HOW.
- Must not write properties that reimplement the algorithm.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
