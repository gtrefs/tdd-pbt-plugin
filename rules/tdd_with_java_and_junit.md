# TDD with Java and JUnit (Jupiter)

## Test File Creation
1. **Create test class** in `src/test/java/` mirroring the production package structure
2. **Use JUnit Jupiter annotations** (`@Test`, `@Disabled`, `@DisplayName`)
3. **Follow TDD red-green-refactor** cycle
4. **Leverage Java's type checking** during development

## Naming Conventions

| Type | Class Suffix | Example | Annotations |
|------|-------------|---------|-------------|
| TDD / Unit Tests | `*Test` | `CalculatorTest.java` | `@Test`, `@Disabled` |
| Property-Based Tests | `*Properties` | `CalculatorProperties.java` | `@Property`, `@ForAll` |

Both are picked up automatically by Maven Surefire (see includes config below).

## Running Tests - CRITICAL REQUIREMENTS

**ALWAYS use Maven goals defined in `pom.xml`**

### Correct - Use Maven goals:
```bash
mvn test                   # Run all tests
mvn test -pl <module>      # Run tests in a specific module
```

### WRONG - DO NOT use these:
```bash
java -jar junit-platform-standalone.jar   # Don't run JUnit directly
mvn exec:java -Dexec.mainClass=...        # Don't invoke test runner manually
```

### Why This Matters
- **Maven goals provide a consistent interface** for running tests
- **Configuration is managed centrally** in pom.xml (Surefire plugin, dependencies)
- **Consistency across development and CI** environments

### Test Goal Overview
- `mvn test` - Runs full test suite via Maven Surefire plugin

**IMPORTANT**: When TDD agents run tests, they MUST use `mvn test`, never invoke JUnit directly.

## Example Test Template (TDD)
```java
// src/test/java/com/example/CalculatorTest.java
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class CalculatorTest {

    @Test
    @Disabled("todo")
    void shouldHandleBasicOperations() {}

    @Test
    @Disabled("todo")
    void shouldValidateInputTypes() {}

    @Test
    @Disabled("todo")
    void shouldHandleEdgeCases() {}
}
```

## Example Property Template (PBT)
```java
// src/test/java/com/example/CalculatorProperties.java
import net.jqwik.api.Disabled;
import net.jqwik.api.ForAll;
import net.jqwik.api.Property;
import net.jqwik.api.constraints.IntRange;

import static org.assertj.core.api.Assertions.assertThat;

class CalculatorProperties {

    @Property
    @Disabled("todo")
    void additionIsCommutative(@ForAll int a, @ForAll int b) {}

    @Property
    @Disabled("todo")
    void addingZeroIsIdentity(@ForAll int a) {}
}
```

## Assertions
Use **AssertJ** for fluent assertions (preferred over plain JUnit assertions):
```java
assertThat(result).isEqualTo(42);
assertThat(list).containsExactly(1, 2, 3);
assertThat(thrown).isInstanceOf(IllegalArgumentException.class);
```

## Recommended pom.xml Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.11.0</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <version>3.26.3</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>net.jqwik</groupId>
        <artifactId>jqwik</artifactId>
        <version>1.9.3</version>
        <scope>test</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.3.1</version>
            <configuration>
                <includes>
                    <include>**/*Test.java</include>
                    <include>**/*Tests.java</include>
                    <include>**/*Properties.java</include>
                </includes>
            </configuration>
        </plugin>
    </plugins>
</build>
```

Note: Adjust dependency versions to match your project's requirements. The key requirement is JUnit Jupiter (any recent version), AssertJ, and jqwik.
