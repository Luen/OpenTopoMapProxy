# AGENTS.md

Agent-focused guidance for this repository ([AGENTS.md format](https://agents.md/)). Human-facing docs live in `README.md`.

## Living document

Treat this file as **living documentation**. Update it in the same PR when the stack, scripts, branch model, deploy path, or other project facts change. Future agents should keep it accurate rather than leaving stale instructions.

## Branch model

| Branch | Role |
| --- | --- |
| `develop` | Default branch for features and improvements |
| `main` | Production. Safe dependency bumps and releases land here |

- Open feature/fix PRs against **`develop`**.
- Promote to **`main`** when ready for production.
- Do not use `master` (rename to `main` if any remnant remains).

## Dependency and deploy notes

### Tier C - Branches + agent docs

- No nightly Docker dependency-release workflow in this rollout.
- Use `develop` for features and `main` for production when applicable.

## Pull requests

Before merging any pull request:

1. Read all PR comments (conversation, review, and bot) and address or acknowledge them.
2. Wait for required CI checks to pass before merging.
