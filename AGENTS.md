# AGENTS.md

Agent-focused guidance for this repository ([AGENTS.md format](https://agents.md/)). Human-facing docs live in `README.md`.

## Living document

Treat this file as **living documentation**. Update it in the same PR when the stack, scripts, branch model, deploy path, or other project facts change. Future agents should keep it accurate rather than leaving stale instructions.

## Project overview

OpenTopoMap nginx tile cache/proxy (static HTML + nginx proxy cache). No Node app.

## Branch model

| Branch | Role |
| --- | --- |
| `dev` | Default branch for features and improvements |
| `main` | Production. Releases and GHCR images land here |

- Open feature/fix PRs against **`dev`**.
- To release: merge **`dev` into `main`**, tag, and create a GitHub Release on `main`.
  Publishing the Release triggers `.github/workflows/release-publish.yml`, which
  builds and pushes the GHCR image. A tag alone does **not** publish an image.
- Do not use `master` (rename to `main` if any remnant remains).
- **Keep `dev` and `main` in sync.**

## Dependency and deploy notes

### Tier B - Docker services (GHCR)

- No npm/pnpm app lockfile — nginx image only (digest-pinned base in `Dockerfile`).
- Image: `ghcr.io/luen/opentopomapproxy` (lowercase). Tags: `:latest`, `:<tag>`, `:<sha>`
- Publish via `.github/workflows/release-publish.yml` (`release: published` or `workflow_dispatch`).
- Auth for Actions: `GITHUB_TOKEN` with `packages: write` (no Docker Hub secrets).
- Servers should pull/recreate from GHCR (e.g. Watchtower) using a PAT with `read:packages`.
- Prefer `docker compose up -d --no-build` on servers after `docker compose pull`.

## Pull requests

Before merging any pull request:

1. Read all PR comments (conversation, review, and bot) and address or acknowledge them.
2. Wait for required CI checks to pass before merging.
