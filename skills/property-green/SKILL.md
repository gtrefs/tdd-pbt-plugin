---
name: property-green
description: Use after the Property Red phase to implement the minimal code that makes a failing property pass for ALL generated inputs. Triggers on phrases like "make the property pass", "property green phase", "yes proceed to Green", "let's go property green". Unlike TDD Green, hardcoded returns are not acceptable — the implementation must generalize across all generated inputs. Stops and waits for user approval before Refactor.
---

# /tdd-pbt:property-green — Property-First Development: Green Phase

`/tdd-pbt:property-green` launches the `property-green` agent to implement the minimal code that makes a failing property pass for **all** generated inputs. This is Step 3 of the Property-First Development cycle.

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
     - Java: `src/test/java/<package>/<ClassName>Properties.java`
     - TypeScript: `src/<ClassName>.properties.test.ts`
   - Name of the failing property and what it asserts
   - The shrunk counterexample from the Red phase
   - Implementation file path:
     - Java: `src/main/java/<package>/<ClassName>.java`
     - TypeScript: `src/<ClassName>.ts`

2. Call the `property-green` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Properties file: <path to properties file>
   Failing property: "<propertyMethodName>"
   Property asserts: <description of what the property checks>
   Counterexample: <shrunk input from PBT framework>
   Implementation file: <path to production code>
   ```

3. The agent will:
   - Analyze the failing property and its counterexample
   - Implement the minimal code that satisfies the property for ALL generated inputs
   - Java: Run `mvn test` and verify the property now passes
   - TypeScript: Run `npx vitest run` and verify the property now passes
   - Confirm no previously passing properties regressed
   - Stop and ask for approval before Refactor phase

4. After the agent completes and reports "Green phase complete", wait for the user to confirm before proceeding to `/tdd-pbt:refactor`.

## Key Difference from TDD Green

In TDD Green, a hardcoded return value is acceptable because the test checks one specific input.

In PBT Green, hardcoding is **not acceptable** — the property must hold for all generated inputs. The implementation must be general enough to satisfy the property across the full input space, while still being minimal (only satisfying the current property, not future ones).

## Property-First Development Cycle

After Green phase completes: use `/tdd-pbt:refactor` (the same refactor agent as TDD) to improve code quality, then loop back to `/tdd-pbt:property-red` for the next property.

## What you must NOT do

- Must not hardcode return values for specific counterexamples.
- Must not implement features demanded only by future properties.
- Must not refactor — that is strictly the Refactor agent's responsibility.
- Must not proceed to Refactor phase without explicit user approval.
- Must not combine the Green and Refactor phases into a single agent call.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
