# tdd-pbt Plugin

**Name:** tdd-pbt
**Version:** 0.1.0
**Author:** Gregor Trefs (Gregor.Trefs@gmail.com)

## Description

A reusable Claude Code plugin that packages TDD (Test-Driven Development) and PBT (Property-Based Testing) workflow skills and agents.

The plugin enforces the Red-Green-Refactor cycle with human-in-the-loop checkpoints, specialized sub-agents for each TDD phase, and jqwik-based Property-Based Testing support for Java projects using JUnit 6.

## Contents

| Directory | Purpose |
|-----------|---------|
| `agents/` | Sub-agent definitions for each TDD and PBT phase (red, green, refactor, test-list, find-properties, etc.) |
| `skills/` | Reusable skill definitions (e.g., graphify) |
| `rules/` | Rule files enforcing TDD discipline, PBT conventions, and human-in-the-loop checkpoints |

## Compatibility

- Claude Code CLI
- Java projects using Maven, JUnit 6 (Jupiter), AssertJ, and jqwik

## License

MIT
