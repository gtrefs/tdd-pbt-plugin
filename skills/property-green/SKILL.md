---
name: property-green
description: Use after the Property Red phase to implement the minimal code that makes a failing property pass for ALL generated inputs. Triggers on phrases like "make the property pass", "property green phase", "yes proceed to Green", "let's go property green". Unlike TDD Green, hardcoded returns are not acceptable — the implementation must generalize across all jqwik-generated inputs. Stops and waits for user approval before Refactor.
---

# /tdd-pbt:property-green — Property-First Development: Green Phase

`/tdd-pbt:property-green` launches the `property-green` agent to implement the minimal code that makes a failing property pass for **all** generated inputs. This is Step 3 of the Property-First Development cycle.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Properties file path
   - Name of the failing property and what it asserts
   - The shrunk counterexample from the Red phase
   - Implementation file path

2. Call the `property-green` agent with all collected context as the prompt. Include:
   ```
   Properties file: <path to *Properties.java>
   Failing property: "<propertyMethodName>"
   Property asserts: <description of what the property checks>
   Counterexample: <shrunk input from jqwik>
   Implementation file: <path to production code>
   ```

3. The agent will:
   - Analyze the failing property and its counterexample
   - Implement the minimal code that satisfies the property for ALL generated inputs
   - Run `mvn test` and verify the property now passes
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
