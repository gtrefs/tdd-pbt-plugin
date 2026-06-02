---
name: property-red
description: Use to activate one placeholder property from the property list and verify it fails. Triggers on phrases like "activate the first property", "property red phase", "let's go property red", "next property". Activates exactly one property, predicts failure, verifies the counterexample. Stops and waits for user approval before proceeding to property-green.
---

# /tdd-pbt:property-red — Property-First Development: Red Phase

`/tdd-pbt:property-red` launches the `property-red` agent to activate exactly one placeholder property, predict how the PBT framework will find a counterexample, and verify the failure. This is Step 2 of the Property-First Development cycle.

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
   - Properties file path
   - Which placeholder property to activate (name or "next one"):
     - Java: `@Disabled("todo")` property
     - TypeScript: `test.todo(...)` property
   - Implementation file path
   - Current number of passing properties

2. Call the `property-red` agent with all collected context as the prompt. Include:
   ```
   Language: <java|typescript>
   Properties file: <path to properties file>
   Activate property: "<propertyMethodName>" (or "next placeholder property")
   Current state: <N> properties passing
   Implementation file: <path to production code>
   ```

3. The agent will:
   - Activate exactly one property (write the full property body):
     - Java: Remove `@Disabled("todo")`, add `@ForAll` parameters and assertions
     - TypeScript: Replace `test.todo(...)` with `it('...', () => { fc.assert(fc.property(...)) })`
   - Predict how the PBT framework will fail: compilation/type error or counterexample with shrunk input
   - If no production class/method exists: create empty class/method with default return, then re-run
   - Verify the property fails as predicted
   - If prediction was wrong, stop and explain the discrepancy
   - Stop and ask for approval before Green phase

4. After the agent completes and reports "Red phase complete", wait for the user to confirm before proceeding to `/tdd-pbt:property-green`.

## Key Difference from TDD Red

In TDD Red, the failure is a specific assertion error (`expected: X but was: Y`).
In PBT Red, the failure is the framework finding a **counterexample** — a generated input for which the property does not hold. The framework then shrinks this to the minimal failing input.

## What you must NOT do

- Must not activate more than one property at a time.
- Must not skip the counterexample prediction step.
- Must not write implementation code beyond an empty class/method stub.
- Must not proceed to property-green without explicit user approval.
- Must not ignore the shrunk counterexample that the PBT framework reports.
- Must not overwrite `.tdd-pbt/config.yml` if it already exists.
