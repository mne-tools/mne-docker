# MNE docker images

Docker images for MNE

1. Base image to use for cloud scheduler and workers (headless)
2. Jupyter Notebook image to use as helper entrypoint


## Releasing

Building and releasing new image versions is done automatically via GitHub Actions. When new commits are
pushed to the master branch images are built with the `dev` tag and pushed to Docker Hub.
