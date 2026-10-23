#!/bin/bash

# Remove package caches and files not needed at runtime. Call this in the same RUN
# step as the install, otherwise the deleted files still ship in the earlier layer.

set -eo pipefail

micromamba clean --all --yes
find ${MAMBA_ROOT_PREFIX} -type f,l -name '*.a' -delete
find ${MAMBA_ROOT_PREFIX} -type f,l -name '*.pyc' -delete
find ${MAMBA_ROOT_PREFIX} -type f,l -name '*.js.map' -delete
rm -rf ${MAMBA_ROOT_PREFIX}/pkgs
