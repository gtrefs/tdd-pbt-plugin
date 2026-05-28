# tdd-pbt — Claude Code Plugin

A reusable Claude Code plugin packaging TDD and Property-Based Testing workflow agents, rules, and skills. Designed for workshop facilitators running the "TDD and PBT" kata sessions.

## What is included

- **Agents**: Specialized sub-agents for each phase of the TDD and PBT cycles (red, green, refactor, test-list, property-list, find-properties, implement-properties, property-red, property-green)
- **Rules**: Enforcement rules for Red-Green-Refactor discipline, jqwik PBT conventions, human-in-the-loop checkpoints, and Java/JUnit 6 setup
- **Skills**: Reusable skill definitions (populated in tasks 02 and 03)

## Installing the plugin (local / offline)

Claude Code supports installing plugins directly from a local directory. This is the recommended approach for workshop facilitators who need offline installs.

### Step 1 — Register the plugin directory as a local marketplace

Run this once per facilitator machine, pointing at the directory that *contains* the plugin folder (i.e., the project root or a dedicated plugins checkout):

```bash
claude plugin marketplace add /path/to/tdd-and-pbt-javaland-2026
```

This registers the project root as a local marketplace named after its directory.

### Step 2 — Install the plugin from the local marketplace

```bash
claude plugin install tdd-pbt@tdd-and-pbt-javaland-2026
```

If the marketplace was registered under a different name (check with `claude plugin marketplace list`), substitute that name after the `@`.

To install for a single project only (project scope):

```bash
claude plugin install tdd-pbt@tdd-and-pbt-javaland-2026 --scope project
```

### Step 3 — Verify installation

```bash
claude plugin list
```

The output should include `tdd-pbt` with version `0.1.0`.

### Step 4 — Restart Claude Code

After installation, restart the Claude Code session (close and reopen the terminal or run `/reset`) so the new agents, rules, and skills are picked up.

## Updating the plugin

After pulling new changes from the repo:

```bash
claude plugin update tdd-pbt
```

## Uninstalling

```bash
claude plugin uninstall tdd-pbt
```

## Local marketplace structure

For the plugin to be discoverable, the directory registered as a marketplace must contain a subdirectory named `tdd-pbt-plugin/` with a valid `.claude-plugin/plugin.json` manifest. The current layout is:

```
tdd-and-pbt-javaland-2026/        <- register this as the marketplace root
└── tdd-pbt-plugin/               <- the plugin itself
    ├── .claude-plugin/
    │   └── plugin.json           <- machine-readable manifest (required)
    ├── PLUGIN.md                 <- human-readable manifest
    ├── agents/                   <- agent definitions
    ├── rules/                    <- rule files
    ├── skills/                   <- skill definitions
    └── README.md                 <- this file
```

## Validating the manifest

```bash
claude plugin validate /path/to/tdd-and-pbt-javaland-2026/tdd-pbt-plugin
```

## Troubleshooting

| Problem | Resolution |
|---------|-----------|
| `plugin not found` after install | Run `claude plugin marketplace update` then retry install |
| Agents not available after install | Restart the Claude Code session |
| Wrong marketplace name | Run `claude plugin marketplace list` to see registered names |
