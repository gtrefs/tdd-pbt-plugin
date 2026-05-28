# Property-Based Testing (PBT) with jqwik

## Overview

This plugin supports two PBT workflows:
1. **PBT as Safety Net**: Properties written AFTER TDD to harden the implementation
2. **Property-First Development**: Properties drive the implementation (like TDD but with properties)

## What is a Property?

A property is a statement that must hold true for ALL valid inputs, not just specific examples.

### Common Property Categories

| Category | Description | Example |
|----------|-------------|---------|
| **Invariant** | Something that never changes | "Output size equals input size times factor" |
| **Roundtrip** | encode → decode = identity | "serialize then deserialize returns original" |
| **Idempotence** | f(f(x)) = f(x) | "sorting a sorted list gives the same list" |
| **Symmetry** | f(a,b) = f(b,a) | "distance(a,b) = distance(b,a)" |
| **Induction** | f(n) relates to f(n-1) | "fib(n) = fib(n-1) + fib(n-2)" |
| **Hard to compute, easy to verify** | Check result rather than algorithm | "isPrime(p) → no divisor between 2 and sqrt(p)" |
| **Test oracle** | Compare with known-correct implementation | "mySort(list) = Collections.sort(list)" |

## jqwik Conventions

### Annotations
- `@Property` — marks a property-based test method
- `@ForAll` — marks a parameter for automatic generation
- `@Disabled("todo")` — placeholder for not-yet-implemented properties

### Constraints (common)
```java
@ForAll @IntRange(min = 0, max = 100) int value
@ForAll @StringLength(min = 1, max = 50) String text
@ForAll @Size(min = 1, max = 10) List<Integer> list
@ForAll @Positive int positiveNumber
```

### Custom Generators with `@Provide`
```java
@Property
void myProperty(@ForAll("validInputs") MyType input) { ... }

@Provide
Arbitrary<MyType> validInputs() {
    return Arbitraries.integers().between(1, 100).map(MyType::new);
}
```

## Naming Conventions

- **Classes**: `*Properties.java` (e.g., `CalculatorProperties.java`)
- **Methods**: Describe the property as a statement (e.g., `additionIsCommutative`, `outputSizeMatchesInput`)
- **Location**: Same package as production code, under `src/test/java/`

## Assertions

Use **AssertJ** for assertions in properties (same as TDD):
```java
assertThat(result).isEqualTo(expected);
assertThat(list).hasSize(expectedSize);
assertThat(value).isGreaterThanOrEqualTo(0);
```

## Running Tests

`mvn test` runs both `*Test.java` and `*Properties.java` via Maven Surefire.

## PBT Mindset vs. TDD Mindset

| Aspect | TDD | PBT |
|--------|-----|-----|
| **Question** | "What happens for input X?" | "What holds true for ALL inputs?" |
| **Tests** | Specific examples | Universal properties |
| **Failures** | Expected value mismatch | Counterexample found |
| **Debugging** | Look at the specific test | Analyze the shrunk counterexample |
| **Strength** | Documenting specific behavior | Finding unexpected edge cases |

## Agent Usage for PBT

Use the specialized PBT agents for PBT work.

### Workflow 1 — PBT as Safety Net (after TDD)

| Phase | Skill | Agent |
|-------|-------|-------|
| Find Properties | `/tdd-pbt:find-properties` | `find-properties` |
| Implement Properties | `/tdd-pbt:implement-properties` | `implement-properties` |

**Workflow:**
1. Complete TDD cycle (Red → Green → Refactor) using TDD agents
2. `/tdd-pbt:find-properties` — Analyze implementation, identify properties, create `*Properties.java` with `@Disabled("todo")`
3. `/tdd-pbt:implement-properties` — Implement one property at a time, run tests, analyze results
4. Repeat step 3 for each property

### Workflow 2 — Property-First Development

| Phase | Skill | Agent |
|-------|-------|-------|
| Property List | `/tdd-pbt:property-list` | `property-list` |
| Red Phase | `/tdd-pbt:property-red` | `property-red` |
| Green Phase | `/tdd-pbt:property-green` | `property-green` |
| Refactor Phase | `/tdd-pbt:refactor` | `refactor` (reused from TDD) |

**Workflow:**
1. `/tdd-pbt:property-list` — Identify properties for the feature, create `*Properties.java` with `@Disabled("todo")`
2. `/tdd-pbt:property-red` — Activate ONE property, predict failure, verify it fails
3. `/tdd-pbt:property-green` — Minimal implementation to satisfy the property for ALL generated inputs
4. `/tdd-pbt:refactor` — Improve code (reuses existing TDD refactor agent)
5. Repeat from step 2 for next property

### Key Difference: Green Phase in PBT

In TDD Green, you can hardcode a return value for a specific example.
In PBT Green, you **cannot hardcode** — the property must hold for ALL generated inputs.
This means PBT Green often requires more general solutions earlier.

## Shrinking

When jqwik finds a counterexample, it automatically **shrinks** it to the smallest failing input.
- Always analyze the shrunk counterexample, not the original random input
- The shrunk example reveals the boundary of the property violation
- Example: If `@ForAll int n` fails, jqwik might shrink to `n = -1` or `n = 0` — this tells you exactly where the boundary is

## Common PBT Failure Modes

- **Properties too weak**: "result is not null" — tests almost nothing
- **Properties too strong**: Reimplementing the algorithm in the property assertion
- **Missing constraints**: Not constraining `@ForAll` parameters leads to meaningless inputs
- **Ignoring shrinking**: Not analyzing the minimal counterexample
- **Mixing PBT and TDD style**: Writing `assertThat(f(3)).isEqualTo(9)` in a `@Property` — that's an example, not a property
