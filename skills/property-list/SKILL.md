---
name: property-list
description: Use when starting Property-First Development to create a comprehensive property list. Triggers on phrases like "start property-first", "create property list", "identify properties for", "let's do PBT-first". Creates a *Properties.java file with @Disabled("todo") placeholders ordered from simplest to most complex. Does not activate any property — that is the job of /tdd-pbt:property-red.
---

# /tdd-pbt:property-list — Property-First Development: Property List

`/tdd-pbt:property-list` launches the `property-list` agent to identify and list properties for a feature before any implementation begins. This is Step 1 of the Property-First Development cycle.

## What you do

1. Collect context from the user's invocation or the current codebase state:
   - Feature description or requirements
   - Target properties file path (where to create `*Properties.java`)
   - Target implementation file path (where production code will live)

2. Call the `property-list` agent with all collected context as the prompt. Include:
   ```
   Feature: <description of what to implement>
   Properties file: <path for new *Properties.java>
   Implementation file: <path for production code>
   ```

3. The agent will:
   - Analyze the feature requirements
   - Systematically identify properties across all categories (invariants, roundtrips, idempotence, symmetry, hard-to-verify, test oracle)
   - Order properties from simplest to most complex
   - Create a `*Properties.java` file with `@Disabled("todo")` placeholders
   - Present a summary of properties with categories and descriptions

4. After the agent presents the property list, the next step is `/tdd-pbt:property-red` to activate the first property.

## Property-First Development Cycle

```
/tdd-pbt:property-list  →  /tdd-pbt:property-red  →  /tdd-pbt:property-green  →  /tdd-pbt:refactor
                                    ↑_______________________________________________|
                                             (repeat for each property)
```

## What you must NOT do

- Must not implement property bodies — only signatures with `@Disabled("todo")`.
- Must not include advanced properties in the initial list — base functionality only.
- Must not activate any property — that is the job of `/tdd-pbt:property-red`.
- Must not think about implementation — focus on WHAT holds true, not HOW.
- Must not write properties that reimplement the algorithm.
