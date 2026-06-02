#!/usr/bin/env bash
# Fast structural verification for the tdd-pbt plugin.
# Runs in seconds. Checks content invariants without invoking claude.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$PLUGIN_DIR/skills"
AGENTS_DIR="$PLUGIN_DIR/agents"

PASS=0
FAIL=0

check() {
  local description="$1"
  local result="$2"   # "ok" or failure message
  if [ "$result" = "ok" ]; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    echo "        $result"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== tdd-pbt fast verify ==="
echo ""
echo "-- Skills: every non-tutorial skill has Step 0 language detection --"

NON_TUTORIAL_SKILLS="test-list red green refactor find-properties implement-properties property-list property-red property-green"

for skill in $NON_TUTORIAL_SKILLS; do
  skill_file="$SKILLS_DIR/$skill/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    check "$skill: SKILL.md exists" "file not found: $skill_file"
  elif ! grep -q "\.tdd-pbt/config\.yml" "$skill_file"; then
    check "$skill: Step 0 reads .tdd-pbt/config.yml" "string '.tdd-pbt/config.yml' not found in $skill_file"
  else
    check "$skill: Step 0 reads .tdd-pbt/config.yml" "ok"
  fi
done

echo ""
echo "-- Tutorial: never writes .tdd-pbt/config.yml --"

TUTORIAL_FILE="$SKILLS_DIR/tutorial/SKILL.md"
if ! grep -q "NEVER writes \`\.tdd-pbt/config\.yml\`\|never writes \.tdd-pbt/config\.yml\|tutorial NEVER writes" "$TUTORIAL_FILE"; then
  check "tutorial: contains explicit 'never writes config' statement" "statement not found in $TUTORIAL_FILE"
else
  check "tutorial: contains explicit 'never writes config' statement" "ok"
fi

# Check that the tutorial skill itself never instructs writing the config.
# Allow references that describe what *other* skills do (e.g. handoff notes).
# A forbidden write instruction looks like an imperative sentence in first-person
# context: "write .tdd-pbt/config.yml" not prefixed by "It will" or "(It will".
FORBIDDEN=$(grep -n "write.*\.tdd-pbt/config\.yml\|config\.yml.*write" "$TUTORIAL_FILE" \
  | grep -v "NEVER writes\|Must not write\|never writes\|It will.*write\|(It will" || true)
if [ -n "$FORBIDDEN" ]; then
  check "tutorial: does not contain write-config instruction" \
    "found unexpected write instruction(s): $FORBIDDEN"
else
  check "tutorial: does not contain write-config instruction" "ok"
fi

echo ""
echo "-- Tutorial: language selection before flow selection --"

if grep -q "Step 0" "$TUTORIAL_FILE" && grep -q "Step 1" "$TUTORIAL_FILE"; then
  # Check Step 0 appears before the flow selection (Orient the user)
  step0_line=$(grep -n "Step 0" "$TUTORIAL_FILE" | head -1 | cut -d: -f1)
  step1_line=$(grep -n "Step 1" "$TUTORIAL_FILE" | head -1 | cut -d: -f1)
  if [ "$step0_line" -lt "$step1_line" ]; then
    check "tutorial: Step 0 (language) appears before Step 1 (orient)" "ok"
  else
    check "tutorial: Step 0 (language) appears before Step 1 (orient)" "Step 0 at line $step0_line is not before Step 1 at line $step1_line"
  fi
else
  check "tutorial: Step 0 (language) appears before Step 1 (orient)" "Step 0 or Step 1 not found in $TUTORIAL_FILE"
fi

echo ""
echo "-- Agents: every agent has a Language variants section --"

AGENTS="test-list red green refactor find-properties implement-properties property-list property-red property-green"

for agent in $AGENTS; do
  agent_file="$AGENTS_DIR/$agent.md"
  if [ ! -f "$agent_file" ]; then
    check "$agent: agent file exists" "file not found: $agent_file"
  elif ! grep -q "## Language variants" "$agent_file"; then
    check "$agent: has '## Language variants' section" "'## Language variants' not found in $agent_file"
  else
    check "$agent: has '## Language variants' section" "ok"
  fi
done

echo ""
echo "-- Agents: both java and typescript covered in each Language variants section --"

for agent in $AGENTS; do
  agent_file="$AGENTS_DIR/$agent.md"
  [ -f "$agent_file" ] || continue
  if ! grep -q "Language: java\|language.*java\|jqwik" "$agent_file"; then
    check "$agent: Java variant documented" "no Java/jqwik reference in $agent_file"
  else
    check "$agent: Java variant documented" "ok"
  fi
  if ! grep -q "Language: typescript\|language.*typescript\|fast-check\|vitest\|Vitest" "$agent_file"; then
    check "$agent: TypeScript variant documented" "no TypeScript/fast-check/vitest reference in $agent_file"
  else
    check "$agent: TypeScript variant documented" "ok"
  fi
done

echo ""
echo "-- Plugin metadata --"

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
if ! grep -q "typescript\|fast-check\|vitest" "$PLUGIN_JSON"; then
  check "plugin.json: contains typescript keywords" "no typescript/fast-check/vitest keyword in $PLUGIN_JSON"
else
  check "plugin.json: contains typescript keywords" "ok"
fi

echo ""
echo "-- No [TBD] placeholders in skills or agents --"

TBD_COUNT=$(grep -rn "\[TBD\]" "$SKILLS_DIR" "$AGENTS_DIR" 2>/dev/null | wc -l || true)
TBD_COUNT=${TBD_COUNT// /}
if [ "$TBD_COUNT" -gt 0 ]; then
  check "no [TBD] in skills/agents" "found $TBD_COUNT occurrence(s):"
  grep -rn "\[TBD\]" "$SKILLS_DIR" "$AGENTS_DIR" 2>/dev/null | sed 's/^/        /' || true
else
  check "no [TBD] in skills/agents" "ok"
fi

echo ""
echo "-- Frontmatter: every SKILL.md has name and description --"

ALL_SKILLS="test-list red green refactor find-properties implement-properties property-list property-red property-green tutorial"
for skill_name in $ALL_SKILLS; do
  skill_file="$SKILLS_DIR/$skill_name/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    check "$skill_name: SKILL.md exists" "file not found: $skill_file"
  elif ! grep -q "^name:" "$skill_file"; then
    check "$skill_name: frontmatter has 'name'" "missing 'name:' in $skill_file"
  elif ! grep -q "^description:" "$skill_file"; then
    check "$skill_name: frontmatter has 'description'" "missing 'description:' in $skill_file"
  else
    check "$skill_name: frontmatter complete" "ok"
  fi
done

echo ""
echo "================================="
echo "PASS: $PASS   FAIL: $FAIL"
echo "================================="

[ "$FAIL" -eq 0 ]
