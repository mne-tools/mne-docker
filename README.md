# MNE-docker

This repository stores the files to create [docker](https://docs.docker.com/get-docker/) images
capable of running [MNE-Python](https://mne.tools).
This repository also hosts the code and runs the github actions to build and release these images publicly.

## Getting started

To download a notebook capable MNE docker image and launch a jupyter lab session run:

```bash
docker run -p 8888:8888 ghcr.io/mne-tools/mne-python jupyter-lab
```

## Available Docker images

The repository contains several images:

1. `mne-tools/mne-python`: contains a minimal MNE-Python installation that can run python scripts. It does not contain 3D plotting capabilities or a notebook server
2. `mne-tools/mne-python-plot`: adds 2D and 3D plotting capabilities to the base image.
3. `mne-tools/mne-python-notebook`: adds jupyter lab and notebook capabilities to the plot image.

Several versions of the image are stored that correspond to different MNE-Python versions.
Images are also build with from the main branch of MNE-Python, these contain _dev_ in the name.
For example:

* `mne-tools/mne-python:0.23.0` would contain the minimal installation with MNE-Python version 0.23.0.
* `mne-tools/mne-python-plot:latest` would contain the plotting capable image with  the latest MNE-Python release version.
* `mne-tools/mne-python-dev-notebook` would contain the notebook image with the development version of MNE-Python.


## Building images

Docker compose provides an easy way to building all the images with the right context

```
docker-compose build

# Just build one image e.g. notebook
docker-compose build notebook
```

## Releasing

Building and releasing new image versions is done automatically via GitHub Actions. When new commits are
pushed to the master branch images are built with the `dev` tag and pushed to Docker Hub.

When a new version of mne-python is released a PR should be raised to bump the versions in
the `Dockerfile`s and then once that has been merged a new tag matching the mne-python version
should be pushed. GitHub Actions will then build the images and push them with version tags and update
`latest` too.
