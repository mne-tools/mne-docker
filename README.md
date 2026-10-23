# MNE-docker

This repository stores the files to create [docker](https://docs.docker.com/get-docker/) images
capable of running [MNE-Python](https://mne.tools).
This repository also hosts the code and runs the github actions to build and release these images publicly.

## Getting started

To download a notebook capable MNE docker image and launch a jupyter lab session run:

```bash
docker run -p 8888:8888 ghcr.io/mne-tools/mne-python-jupyter jupyter lab --ip="*"
```

## Available Docker images

The repository contains several images, each built for `linux/amd64` and `linux/arm64`:

1. `ghcr.io/mne-tools/mne-python`: contains a minimal MNE-Python installation that can run python scripts.
2. `ghcr.io/mne-tools/mne-python-jupyter`: adds jupyter lab to the base image.
3. `ghcr.io/mne-tools/mne-python-plot`: adds 2D and 3D plotting capabilities to the `mne-python-jupyter` image.

Several versions of the image are stored that correspond to different MNE-Python versions.
This allows you to specify which version of MNE-Python you wish to run.
Additionally, if you wish to use the latest development version, you can specify the `main` tag,
which is rebuilt weekly.
For example:

* `ghcr.io/mne-tools/mne-python:latest` would use the latest released MNE-Python version, e.g. v1.13.2.
* `ghcr.io/mne-tools/mne-python:v1.13.2` would use the MNE-Python version 1.13.2.
* `ghcr.io/mne-tools/mne-python:main` would use the development version of MNE-Python.

For example, to run the MNE-Python version v1.13.2 image,
with plotting capabilities,
mount the local directory,
and start up a notebook server run:

```bash
docker run -p 8888:8888 -v `pwd`:/home/mne_user ghcr.io/mne-tools/mne-python-plot:v1.13.2 jupyter-lab --ip="*"
```

## Customizing a container

The Python environment lives in `/opt/conda` and is managed with
[micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html)
(there is no `conda` command). Packages are installed from conda-forge, e.g.
`micromamba install -y -n base tqdm`. Additional packages can also be installed
when the container starts via:

* `EXTRA_APT_PACKAGES`, `EXTRA_CONDA_PACKAGES`, or `EXTRA_PIP_PACKAGES` environment variables
  (space-separated package names), e.g. `docker run -e EXTRA_PIP_PACKAGES=mne-bids ...`.
* An `environment.yml` mounted at `/opt/app/environment.yml`.

## Building images

Docker compose provides an easy way to build all the images in the right order:

```bash
docker compose build

# Build with a specific MNE-Python version (a release tag or a GitHub ref like main)
docker compose build --build-arg mne_v=main
```

## Releasing

Building and releasing new image versions is done automatically via GitHub Actions, which
builds and tests the images natively on amd64 and arm64 runners and pushes them to the
GitHub container registry. When new commits are pushed to the main branch (and weekly),
images are built with the development version of MNE-Python and pushed with the `main` tag.

When a new version of mne-python is released, a PR should be opened to bump the default `mne_v` in
`base/Dockerfile`. Once that has been merged, a tag matching the mne-python version (e.g., `v1.13.2`)
should be pushed to this repository. GitHub Actions will then build the images and push them with the
version tag, and update `latest` too.

Images for a specific MNE-Python version can also be built manually via the "Run workflow" button
(`workflow_dispatch`) of the Tests workflow, which pushes only the version tag.
