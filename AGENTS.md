# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this is

MNE-Docker builds Docker images with MNE-Python preinstalled and publishes them to the
GitHub container registry (`ghcr.io/mne-tools/...`). There is no Python package here: the
repository is a set of Dockerfiles, a `docker-compose.yml` that ties them together, a
GitHub Actions workflow that builds, tests, and pushes them, and two small smoke-test
scripts.

## Follow MNE-Python's conventions

This repository is a subsidiary of MNE-Python. Unless something below says otherwise,
follow [MNE-Python's AGENTS.md](https://github.com/mne-tools/mne-python/blob/main/AGENTS.md)
(read it rather than guessing), and in particular its
[policy on AI assistance](https://github.com/mne-tools/mne-python/blob/main/CONTRIBUTING.md#policy-on-ai-assistance-in-contributions):

- Do not open pull requests, push, or commit unless explicitly asked; the human submitting
  the change must review, understand, and disclose AI use in the PR description.
- Keep changes minimal and scoped to the request; mention, don't silently fix, unrelated
  problems you notice.
- Do not paste agent-written text into issues, PRs, or comments.

What does *not* carry over from MNE-Python: there is no changelog, no towncrier
fragments, no docs build, no pytest suite, and no pre-commit configuration.

## Things to know

- The images form a chain (see `docker-compose.yml`): `base/Dockerfile`
  (`ghcr.io/mne-tools/mne-python`, built `FROM` the `mambaorg/micromamba` Ubuntu image) →
  `base/Dockerfile.jupyter` (`-jupyter`, adds JupyterLab) → `base/Dockerfile.plot`
  (`-plot`, adds Xvfb, VTK/PyVista, Qt, and `mne-qt-browser`). The later Dockerfiles use
  `FROM base` / `FROM jupyter`, which Compose resolves to the locally built earlier image via
  `additional_contexts`, so build through `docker compose` (plain `docker build` of them
  fails), and a change to `base/Dockerfile` affects all three.
- The `mne_v` build arg selects MNE-Python: a release tag (`v1.13.2`) installs `mne-base`
  from conda-forge; anything else (e.g., `main`) installs `mne-base` for its dependencies and
  then pip-installs that GitHub ref over it.
- The environment is managed with micromamba only (no `conda` or `mamba` in the image);
  conda-forge is configured as the channel in `/opt/conda/.condarc`.
- `base/prepare.sh` runs at container start (after the micromamba entrypoint activates the
  environment, under `tini`). It installs `EXTRA_APT_PACKAGES` (via a `sudo` rule limited to
  `apt-get`), `/opt/app/environment.yml`, `EXTRA_CONDA_PACKAGES`, and `EXTRA_PIP_PACKAGES`,
  and starts Xvfb when `START_XVFB` is set. These are user-facing; don't rename or drop them.
- Images run as the unprivileged `mne_user` (UID/GID 1001); switch to `USER root` only for
  steps that need it (e.g., `apt-get`) and switch back afterward, as `Dockerfile.plot` does.
- Image size matters: end every `micromamba install` with `cleanup.sh` *in the same `RUN`*
  (a later `RUN` cannot shrink an earlier layer), and prefer adding conda-forge packages to
  the existing install lists over extra layers. New packages must exist for both
  `linux-64` and `linux-aarch64`.
- Which MNE-Python version gets built, and which image tags get pushed, is decided in
  `.github/workflows/main.yml` (the "Set env vars" step), not by the `mne_v` default in
  `base/Dockerfile`. Each architecture is built and tested natively on its own runner and
  pushed as `<tag>-amd64` / `<tag>-arm64`, then the `manifest` job combines them into the
  multi-arch tag. Images are pushed only from `mne-tools/mne-docker` and never for pull
  requests. The release process is described in the README.

## Testing

There is no unit-test suite. CI builds the images and then, for each one, prints
`mne.sys_info()` and runs a smoke test: `tests/base.py` (reads a NIRx dataset, run in the
base and jupyter images) and `tests/plot.py` (renders a 3D sphere off-screen and checks the
screenshot, run in the plot image). To check a change locally, mirror the workflow:

```bash
docker compose build --build-arg mne_v=v1.13.2
docker run -v "$(pwd)":/opt/app/examples ghcr.io/mne-tools/mne-python python /opt/app/examples/tests/base.py
docker run -v "$(pwd)":/opt/app/examples ghcr.io/mne-tools/mne-python-plot python /opt/app/examples/tests/plot.py
```

A local build only covers your machine's architecture, and full builds are slow (several
minutes), so say so if you could not run them and are relying on CI instead.
