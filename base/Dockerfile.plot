# "jupyter" is the mne-python-jupyter image, provided via additional_contexts in docker-compose.yml
FROM jupyter

LABEL org.opencontainers.image.description="MNE-Python with JupyterLab and 2D/3D plotting"

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER $MNE_USER

RUN micromamba install -y -n base vtk pyvista pyvistaqt trame PySide6 qtpy mne-qt-browser trame-vtk trame-vuetify && \
    cleanup.sh

# setup environment for mne
# MNE_3D_OPTION_ANTIALIAS is needed to avoid blank screenshots.
# PYVISTA_OFF_SCREEN=true is *NOT* needed
ENV \
    MNE_3D_BACKEND=pyvistaqt \
    MNE_3D_OPTION_ANTIALIAS=false \
    START_XVFB=true
