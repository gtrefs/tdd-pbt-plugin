---
id: feature-typescript-support
title: Add TypeScript (fast-check + Vitest) support as parallel track
type: feature
status: done
bc: tdd-pbt
depends_on: []
---

## What

Add TypeScript as a parallel language track alongside Java in the tdd-pbt plugin.
A per-project config file (`.tdd-pbt/config.yml`) stores the language choice.
All non-tutorial skills check for this config on entry and ask the user to choose
if it is missing, then persist the choice. The tutorial skill presents a
language/library selection step at the very start (before flow selection) and
uses that choice for the session only — it never writes the config file.
All existing skills and agents get TypeScript variants using fast-check and Vitest.
The Java track retains full support with jqwik pinned to version 1.9.3 as a
fallback option.

## Acceptance criteria

- `.tdd-pbt/config.yml` is created in the user's project when any non-tutorial
  skill is first invoked and no config exists; it contains a `language` field
  set to either `java` or `typescript`
- Every non-tutorial skill (`test-list`, `red`, `green`, `refactor`,
  `find-properties`, `implement-properties`, `property-list`, `property-red`,
  `property-green`) reads `.tdd-pbt/config.yml` on entry and branches on the
  `language` field to deliver the correct language-specific guidance
- The tutorial skill presents a language/library selection step before the flow
  selection step; the selection is used for that session only and `.tdd-pbt/config.yml`
  is never written by the tutorial
- TypeScript variants use fast-check as the PBT library and Vitest as the test
  runner; `test.todo(...)` is the TypeScript equivalent of `@Disabled("todo")`
- Java variants document jqwik 1.9.3 as the supported fallback version
- The tutorial toy problem (`Calculator.add(a, b)`) is fully implemented in both
  language variants with correct file paths (`src/Calculator.ts`,
  `src/Calculator.test.ts` for TypeScript)
- No existing Java/jqwik skill behaviour is changed

## Invariants

- Config is written at most once per project: once `.tdd-pbt/config.yml` exists,
  no skill overwrites it without explicit user action
- The tutorial never writes `.tdd-pbt/config.yml`, regardless of which language
  the user selects during the tutorial session
- Every skill resolves the language from `.tdd-pbt/config.yml` at the same path,
  giving a project exactly one source of truth for the language choice
- The `language` field in `.tdd-pbt/config.yml` is always either `java` or
  `typescript` — never empty, null, or any other value
- The tutorial toy problem (`Calculator.add`) is implemented in both language
  variants so any tutorial session can run end-to-end regardless of the chosen language

## Notes

- jqwik AI-agent disclaimer prompted this work — 1.9.3 is the last clean version
- fast-check is the de facto standard TypeScript PBT library
- Vitest chosen over Jest: faster, native ESM, better TS integration

## Outcome
status: done
method_selected: TDD (documentation/content authoring)
specialists_consulted: []
adrs_produced: []
verify_attempts: 0
bounced_reason: null

invariant tests: skipped
reason: task file invariants are enforced via prose constraints in Markdown skill/agent files, not executable code — no test framework present

slow tier stub: skipped
reason: slow tier not configured (verify.slow is absent from harness config)
