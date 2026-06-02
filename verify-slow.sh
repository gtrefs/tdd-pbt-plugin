#!/usr/bin/env bash
# Slow end-to-end verification for the tdd-pbt plugin.
# Invokes the claude CLI in non-interactive mode against a throwaway directory.
# Requires: claude CLI on PATH, ANTHROPIC_API_KEY set.
# Runtime: ~30–90 seconds (two claude -p invocations).
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

check() {
  local description="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    echo "        $result"
    FAIL=$((FAIL + 1))
  fi
}

# Create a throwaway project directory
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "=== tdd-pbt slow verify ==="
echo "Work dir: $WORK_DIR"
echo ""

# -----------------------------------------------------------------------
# Test 1: TypeScript test-list — config pre-seeded, skill creates test file
# -----------------------------------------------------------------------
echo "-- Test 1: TypeScript test-list creates src/Calculator.test.ts --"

TEST1_DIR="$WORK_DIR/ts-test-list"
mkdir -p "$TEST1_DIR/.tdd-pbt"

# Pre-seed the language config so no interactive question is needed
cat > "$TEST1_DIR/.tdd-pbt/config.yml" <<'EOF'
language: typescript
EOF

# Run the skill non-interactively with enough context to proceed without questions
PROMPT="/tdd-pbt:test-list

Feature: Calculator — add two integers
Test file: src/Calculator.test.ts
Implementation file: src/Calculator.ts
Requirements:
  - add(a, b) returns the sum of a and b
  - Self-contained, no external dependencies
  - Produce 3 tests maximum, all as test.todo(...) placeholders"

(cd "$TEST1_DIR" && claude -p "$PROMPT" \
  --plugin-dir "$PLUGIN_DIR" \
  --dangerously-skip-permissions \
  --output-format text \
  > "$TEST1_DIR/claude-output.txt" 2>&1) \
  || true   # don't abort on non-zero exit; we check file presence below

# Assert: test file was created
if [ ! -f "$TEST1_DIR/src/Calculator.test.ts" ]; then
  check "TypeScript test-list: src/Calculator.test.ts created" \
    "file not found; claude output: $(cat "$TEST1_DIR/claude-output.txt" | tail -20)"
else
  check "TypeScript test-list: src/Calculator.test.ts created" "ok"

  # Assert: file contains test.todo (TypeScript placeholder)
  if grep -q "test\.todo\|it\.todo" "$TEST1_DIR/src/Calculator.test.ts"; then
    check "TypeScript test-list: placeholders use test.todo(...)" "ok"
  else
    check "TypeScript test-list: placeholders use test.todo(...)" \
      "test.todo not found in $(cat "$TEST1_DIR/src/Calculator.test.ts")"
  fi

  # Assert: file does NOT contain @Disabled (Java placeholder leaked)
  if grep -q "@Disabled" "$TEST1_DIR/src/Calculator.test.ts"; then
    check "TypeScript test-list: no @Disabled Java annotation leaked" \
      "@Disabled found in TypeScript file"
  else
    check "TypeScript test-list: no @Disabled Java annotation leaked" "ok"
  fi

  # Assert: file does NOT contain .java extension paths
  if grep -q "\.java" "$TEST1_DIR/src/Calculator.test.ts"; then
    check "TypeScript test-list: no .java paths in TypeScript file" \
      ".java reference found in TypeScript file"
  else
    check "TypeScript test-list: no .java paths in TypeScript file" "ok"
  fi
fi

# Assert: config was NOT re-written (invariant: written at most once)
CONFIG_CONTENT=$(cat "$TEST1_DIR/.tdd-pbt/config.yml")
if [ "$CONFIG_CONTENT" = "language: typescript" ]; then
  check "TypeScript test-list: config.yml not overwritten" "ok"
else
  check "TypeScript test-list: config.yml not overwritten" \
    "config content changed to: $CONFIG_CONTENT"
fi

echo ""

# -----------------------------------------------------------------------
# Test 2: Java test-list — config pre-seeded, skill creates correct Java file
# -----------------------------------------------------------------------
echo "-- Test 2: Java test-list creates src/test/java/CalculatorTest.java --"

TEST2_DIR="$WORK_DIR/java-test-list"
mkdir -p "$TEST2_DIR/.tdd-pbt"

cat > "$TEST2_DIR/.tdd-pbt/config.yml" <<'EOF'
language: java
EOF

PROMPT="/tdd-pbt:test-list

Feature: Calculator — add two integers
Test file: src/test/java/CalculatorTest.java
Implementation file: src/main/java/Calculator.java
Requirements:
  - add(int a, int b) returns the sum of a and b
  - Self-contained, no external dependencies
  - Produce 3 tests maximum, all as @Disabled(\"todo\") placeholders"

(cd "$TEST2_DIR" && claude -p "$PROMPT" \
  --plugin-dir "$PLUGIN_DIR" \
  --dangerously-skip-permissions \
  --output-format text \
  > "$TEST2_DIR/claude-output.txt" 2>&1) \
  || true

if [ ! -f "$TEST2_DIR/src/test/java/CalculatorTest.java" ]; then
  check "Java test-list: src/test/java/CalculatorTest.java created" \
    "file not found; claude output: $(cat "$TEST2_DIR/claude-output.txt" | tail -20)"
else
  check "Java test-list: src/test/java/CalculatorTest.java created" "ok"

  if grep -q '@Disabled' "$TEST2_DIR/src/test/java/CalculatorTest.java"; then
    check "Java test-list: placeholders use @Disabled" "ok"
  else
    check "Java test-list: placeholders use @Disabled" \
      "@Disabled not found in $(cat "$TEST2_DIR/src/test/java/CalculatorTest.java")"
  fi

  if grep -q "test\.todo\|it\.todo" "$TEST2_DIR/src/test/java/CalculatorTest.java"; then
    check "Java test-list: no test.todo TypeScript syntax leaked" \
      "test.todo found in Java file"
  else
    check "Java test-list: no test.todo TypeScript syntax leaked" "ok"
  fi
fi

echo ""

# -----------------------------------------------------------------------
# Test 3: config.yml not overwritten when already present (idempotency)
# -----------------------------------------------------------------------
echo "-- Test 3: config.yml not overwritten when already present --"

TEST3_DIR="$WORK_DIR/existing-config"
mkdir -p "$TEST3_DIR/.tdd-pbt"

# Pre-seed with typescript; verify it stays unchanged after skill runs
cat > "$TEST3_DIR/.tdd-pbt/config.yml" <<'EOF'
language: typescript
EOF
ORIGINAL_MTIME=$(stat -f "%m" "$TEST3_DIR/.tdd-pbt/config.yml" 2>/dev/null || stat -c "%Y" "$TEST3_DIR/.tdd-pbt/config.yml")

PROMPT="/tdd-pbt:test-list

Feature: Calculator — add two integers
Test file: src/Calculator.test.ts
Implementation file: src/Calculator.ts
Requirements:
  - add(a, b) returns the sum of a and b
  - 2 tests maximum"

(cd "$TEST3_DIR" && claude -p "$PROMPT" \
  --plugin-dir "$PLUGIN_DIR" \
  --dangerously-skip-permissions \
  --output-format text \
  > "$TEST3_DIR/claude-output.txt" 2>&1) \
  || true

LANG_VALUE=$(grep "^language:" "$TEST3_DIR/.tdd-pbt/config.yml" 2>/dev/null | awk '{print $2}' | tr -d '"')
if [ "$LANG_VALUE" = "typescript" ]; then
  check "config.yml not overwritten: language value unchanged" "ok"
else
  check "config.yml not overwritten: language value unchanged" \
    "language field changed to '$LANG_VALUE'"
fi

# Note: "config written on first use" (no pre-existing config) cannot be tested
# non-interactively — the skill's AskUserQuestion call requires a live session.
# That scenario is covered by the fast tier check that all skills contain the
# write-config instruction in their Step 0 preamble.

echo ""
echo "================================="
echo "PASS: $PASS   FAIL: $FAIL"
echo "================================="

[ "$FAIL" -eq 0 ]
