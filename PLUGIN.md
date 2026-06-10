# tdd-pbt Plugin

**Name:** tdd-pbt
**Version:** 0.2.1
**Author:** Gregor Trefs (Gregor.Trefs@gmail.com)

## Description

A reusable Claude Code plugin that packages TDD (Test-Driven Development) and PBT (Property-Based Testing) workflow skills and agents.

The plugin enforces the Red-Green-Refactor cycle with human-in-the-loop checkpoints, specialized sub-agents for each TDD phase, and Property-Based Testing support for both Java and TypeScript projects.

Language is detected automatically from `.tdd-pbt/config.yml` in the user's project directory. Non-tutorial skills create this file on first use if it does not exist. The tutorial skill asks for language choice at session start but never writes the config.

## Contents

| Directory | Purpose |
|-----------|---------|
| `agents/` | Sub-agent definitions for each TDD and PBT phase (red, green, refactor, test-list, find-properties, etc.) |
| `skills/` | Reusable skill definitions for each workflow phase and the interactive tutorial |
| `rules/` | Rule files enforcing TDD discipline, PBT conventions, and human-in-the-loop checkpoints |

## Language Tracks

### Java (jqwik 1.9.3)
- Test runner: Maven (`mvn test`)
- PBT framework: jqwik 1.9.3
- Assertion library: AssertJ
- Test placeholder: `@Disabled("todo")`
- Test file location: `src/test/java/<package>/<ClassName>Test.java`
- Implementation file: `src/main/java/<package>/<ClassName>.java`

### TypeScript (fast-check + Vitest)
- Test runner: Vitest (`npx vitest run`)
- PBT framework: fast-check
- Assertion library: Vitest `expect`
- Test placeholder: `test.todo(...)`
- Test file location: `src/<ClassName>.test.ts`
- Implementation file: `src/<ClassName>.ts`

## Compatibility

- Claude Code CLI
- Java projects using Maven, JUnit 5 (Jupiter), AssertJ, and jqwik 1.9.3
- TypeScript projects using Vitest and fast-check

## License

MIT
