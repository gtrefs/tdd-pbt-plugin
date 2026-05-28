---
name: property-red
description: Use to activate one @Disabled property from the property list and verify it fails. Triggers on phrases like "activate the first property", "property red phase", "let's go property red", "next property". Activates exactly one property, predicts failure, verifies the counterexample. Stops and waits for user approval before proceeding to property-green.
---

# /tdd-pbt:property-red — Property-First Development: Red Phase

`/tdd-pbt:property-red` launches the `property-red` agent to activate exactly one `@Disabled("todo")` property, predict how jqwik will find a counterexample, and verify the failure. This is Step 2 of the Property-First Development cycle.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Properties file path
   - Which `@Disabled("todo")` property to activate (name or "next one")
   - Implementation file path
   - Current number of passing properties

2. Call the `property-red` agent with all collected context as the prompt. Include:
   ```
   Properties file: <path to *Properties.java>
   Activate property: "<propertyMethodName>" (or "next @Disabled property")
   Current state: <N> properties passing
   Implementation file: <path to production code>
   ```

3. The agent will:
   - Activate exactly one property (remove `@Disabled("todo")`, write the full property body)
   - Predict how jqwik will fail: compilation error or counterexample with shrunk input
   - If no production class/method exists: create empty class/method with default return, then re-run
   - Verify the property fails as predicted
   - If prediction was wrong, stop and explain the discrepancy
   - Stop and ask for approval before Green phase

4. After the agent completes and reports "Red phase complete", wait for the user to confirm before proceeding to `/tdd-pbt:property-green`.

## Key Difference from TDD Red

In TDD Red, the failure is a specific assertion error (`expected: X but was: Y`).
In PBT Red, the failure is jqwik finding a **counterexample** — a generated input for which the property does not hold. jqwik then shrinks this to the minimal failing input.

## What you must NOT do

- Must not activate more than one property at a time.
- Must not skip the counterexample prediction step.
- Must not write implementation code beyond an empty class/method stub.
- Must not proceed to property-green without explicit user approval.
- Must not ignore the shrunk counterexample that jqwik reports.
