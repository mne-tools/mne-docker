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

- The images form a chain, built in this order (see `docker-compose.yml`):
  `base/Dockerfile` (`mnetools/mne-python`, micromamba + conda-forge packages + MNE-Python
  installed from a GitHub archive of the `mne_v` build arg) →
  `base/Dockerfile.jupyter` (`mnetools/mne-python-jupyter`, adds JupyterLab) →
  `base/Dockerfile.plot` (`mnetools/mne-python-plot`, adds Xvfb, VTK/PyVista, Qt, and
  `mne-qt-browser`). The later images start `FROM` the locally built earlier ones, so a
  change to `base/Dockerfile` affects all three.
- `base/prepare.sh` is the entrypoint of every image (via `tini`). It installs
  `EXTRA_APT_PACKAGES`, `/opt/app/environment.yml`, `EXTRA_CONDA_PACKAGES`, and
  `EXTRA_PIP_PACKAGES` at container start and starts Xvfb when `START_XVFB` is set. These
  are user-facing; don't rename or drop them.
- Images run as the unprivileged `mne_user`; switch to `USER root` only for steps that
  need it (e.g., `apt-get`) and switch back afterward, as `Dockerfile.plot` does.
- Image size matters: keep the cleanup steps (`conda clean`, deleting `*.a`, `*.pyc`,
  `*.js.map`, and `pkgs`) after package installs, and prefer conda-forge packages in the
  existing `micromamba install` / `conda install` lists over extra layers.
- `notebook/` is legacy: it is not in `docker-compose.yml` or CI and is not maintained.
  Leave it alone unless asked.
- Which MNE-Python version gets built, and which image tags get pushed, is decided in
  `.github/workflows/main.yml` (the "Set env vars" step), not by the `mne_v` default in
  `base/Dockerfile`. Images are pushed only from `mne-tools/mne-docker` on `push` or
  `workflow_dispatch` events; pull requests build and test without pushing. The release
  process is described in the README.

## Testing

There is no unit-test suite. CI builds each image and then, for each one, prints
`mne.sys_info()` and runs a smoke test: `tests/base.py` (reads a NIRx dataset, run in the
base and jupyter images) and `tests/plot.py` (renders a 3D sphere off-screen and checks the
screenshot, run in the plot image). To check a change locally, mirror the workflow:

```bash
docker compose build base --build-arg mne_v=main
docker run -v `pwd`:/opt/app/examples mnetools/mne-python python /opt/app/examples/tests/base.py
docker compose build jupyter plot
docker run -v `pwd`:/opt/app/examples mnetools/mne-python-plot python /opt/app/examples/tests/plot.py
```

Full builds are slow (CI allows 15 minutes for `base` alone), so say so if you could not
run them and are relying on CI instead.
