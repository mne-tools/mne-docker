# MNE docker images

Docker images for MNE

1. Base image to use for cloud scheduler and workers (headless)
2. Jupyter Notebook image to use as helper entrypoint


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
