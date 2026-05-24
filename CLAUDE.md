# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repo produces a customized Docker image based on the official Open WebUI image (`ghcr.io/open-webui/open-webui`), with additional Python packages layered on top. The published image lives at `ghcr.io/ykpaoschool/open-webui-ykps`.

## Build & Run

```bash
# Build (optionally pin a specific upstream version)
docker build --build-arg OPEN_WEBUI_VERSION=main -t open-webui-custom .

# Run
docker run open-webui-ykps
```

The `OPEN_WEBUI_VERSION` build arg maps directly to the upstream image tag (e.g. `main`, `v0.3.30`).

## Adding Dependencies

Edit `requirements.txt` and add the package. The Dockerfile installs these as root, then drops back to user 1000.

## Release

Images are built and pushed to GHCR via the manual **"Build and Publish Custom Open WebUI Image"** GitHub Actions workflow. Trigger it from the Actions tab and provide the desired `open_webui_version` input. The workflow tags the image with both that version string and `latest`.

## Repo Structure

- `Dockerfile` — multi-stage extension of the upstream image; installs extra Python deps
- `requirements.txt` — additional Python packages to layer in
- `.github/workflows/release-image.yml` — manual CI workflow to build & publish to GHCR
