# open-webui-ykps

A customized Docker image based on [Open WebUI](https://github.com/open-webui/open-webui), published to `ghcr.io/ykpaoschool/open-webui-ykps`.

## Versioning

This image tracks upstream Open WebUI stable releases. The currently tracked version lives in [`UPSTREAM_VERSION`](UPSTREAM_VERSION) (e.g. `v0.10.1`), and every image tag mirrors the upstream tag — so `UPSTREAM_VERSION=v0.10.1` produces `ghcr.io/ykpaoschool/open-webui-ykps:v0.10.1`. `latest` always points at the tracked stable version, never at upstream's dev (`main`) branch, which keeps database migrations on the upstream stable release path.

## How upgrades work

- A daily workflow polls upstream for new stable releases and opens a PR bumping `UPSTREAM_VERSION` when one is found.
- Merging that PR triggers CI, which builds and publishes the new version (and moves `latest`).
- Dependency changes (`requirements.txt`) rebuild the *current* tracked version in place — they don't advance the Open WebUI baseline.

See [CLAUDE.md](CLAUDE.md) for the full workflow details.
