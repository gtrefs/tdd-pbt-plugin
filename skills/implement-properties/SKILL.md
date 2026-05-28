---
name: implement-properties
description: Use after find-properties to implement one @Disabled property at a time and analyze jqwik results. Triggers on phrases like "implement the next property", "let's implement properties", "next property please". Implements exactly one property, runs mvn test, analyzes any counterexample. Stops and waits for user approval before the next property.
---

# /tdd-pbt:implement-properties — PBT Safety Net: Implement Properties

`/tdd-pbt:implement-properties` launches the `implement-properties` agent to implement one `@Disabled("todo")` property at a time and analyze the results from jqwik.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Properties file path (the `*Properties.java` file with `@Disabled` placeholders)
   - Implementation file path (the production code under test)
   - Which property to implement (name or "next one" meaning the first remaining)

2. Call the `implement-properties` agent with all collected context as the prompt. Include:
   ```
   Properties file: <path to *Properties.java>
   Implementation file: <path to production code>
   Implement property: "<propertyMethodName>" (or "next @Disabled property")
   ```

3. The agent will:
   - Select exactly one `@Disabled("todo")` property
   - Remove `@Disabled("todo")` and write the property body with appropriate generators and assertions
   - Run `mvn test` and analyze the result
   - If jqwik finds a counterexample, explain the shrunk input and its implications
   - Stop and ask for approval before the next property

4. After the agent completes and reports the result, wait for the user to confirm before proceeding to the next property.

## What you must NOT do

- Must not implement more than one property at a time.
- Must not modify the production implementation.
- Must not write properties that reimplement the algorithm.
- Must not ignore counterexamples — always analyze the shrunk input.
- Must not proceed to the next property without explicit user approval.
