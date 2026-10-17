# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repo produces a customized Docker image based on the official Open WebUI image (`ghcr.io/open-webui/open-webui`), with additional Python packages layered on top. The published image lives at `ghcr.io/ykpaoschool/open-webui-ykps`.

## Build & Run

```bash
# Build (optionally pin a specific upstream version; defaults to UPSTREAM_VERSION)
docker build --build-arg OPEN_WEBUI_VERSION=$(cat UPSTREAM_VERSION) -t open-webui-custom .

# Run
docker run open-webui-ykps
```

The `OPEN_WEBUI_VERSION` build arg maps directly to the upstream image tag (e.g. `main`, `v0.10.1`).

## Adding Dependencies

Edit `requirements.txt` and add the package. The Dockerfile installs these as root (matching the upstream root runtime).

## Versioning & Release

The source of truth for the tracked upstream version is [`UPSTREAM_VERSION`](UPSTREAM_VERSION) — a single line holding the upstream tag (e.g. `v0.10.1`). Every build uses this as its base, so upgrades follow upstream's stable release sequence and the database never gets migrated by a `main`/dev build.

Three workflows cooperate:

- **`track-upstream.yml`** — runs daily (and on manual dispatch). Lists `open-webui/open-webui`'s recent releases, filters out drafts and prereleases, and if any stable version is newer than `UPSTREAM_VERSION`, opens a PR bumping the file to the *oldest* missing one. Merge the PR to upgrade.
- **`ci-build.yml`** — runs on every push to `main` (dependency changes *and* upstream bumps). Reads `UPSTREAM_VERSION`, builds the image, and tags it with the version string, the commit SHA, and `latest`. Rebuilding the same version after a dependency change refreshes the deps without moving the upstream baseline.
- **`release-image.yml`** — manual escape hatch for one-off builds (e.g. rebuilding an old version for rollback testing, or building `main` for verification). Defaults to `UPSTREAM_VERSION` when no version is given; does **not** tag `latest` unless explicitly opted in.

`latest` is only ever written by `ci-build.yml` (i.e. from a stable `UPSTREAM_VERSION`), never from upstream `main`.

### Why upstream tracking reads the release list, and bumps one version per run

`track-upstream.yml` queries `releases?per_page=100` instead of `releases/latest`. Upstream can publish several stable versions between two daily polls, and asking only for the latest one made the versions in between invisible — `v0.12.1` (published 2026-10-14, four hours before `v0.12.2`) was never queried and was silently skipped. The list is filtered (`draft`/`prerelease` dropped, tags must be semver-shaped so `main` or `v0.12.0-rc1` can never be selected), sorted numerically, and the workflow bumps to the **oldest** missing version.

Catch-up is deliberately serial: each run opens at most one PR, and the next gap is picked up by the next daily run after that PR merges. Do not change this to "one PR per gap" — every bump edits the same single-line `UPSTREAM_VERSION`, so parallel PRs conflict and go stale as soon as one merges. Do not backfill by pointing `UPSTREAM_VERSION` at an older tag either: `latest` is derived from that file by `ci-build.yml` and must only ever move forward. An already-skipped version is backfilled with a manual `release-image.yml` dispatch (`tag_latest` off), which is how `v0.12.1` was recovered.

To verify a change to this workflow: dispatch it with `dry_run=true` (the default for manual runs) — it prints the current version, the stable releases in the window, and the full gap list to the job summary without touching anything. Add `simulate_current_version=v0.11.0` to fake the pinned version and exercise the gap logic against real upstream data.

## Repo Structure

- `Dockerfile` — multi-stage extension of the upstream image; installs extra Python deps
- `requirements.txt` — additional Python packages to layer in
- `UPSTREAM_VERSION` — the tracked upstream Open WebUI tag (source of truth for builds)
- `.github/workflows/track-upstream.yml` — daily poll of upstream releases; opens bump PR
- `.github/workflows/ci-build.yml` — builds & publishes on push to main (version + sha + latest)
- `.github/workflows/release-image.yml` — manual escape-hatch build & publish
