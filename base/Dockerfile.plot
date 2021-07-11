FROM mnetools/mne-python

ENV DEBIAN_FRONTEND=noninteractive

# install xvfb
USER root
RUN apt-get update && \
    apt-get install -y xvfb qt5-default && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $MNE_USER
WORKDIR $HOME_DIR

RUN pip install vtk pyvista pyvistaqt PyQt5 matplotlib nibabel joblib h5py mne

# setup environment for mne
# MNE_3D_OPTION_ANTIALIAS is needed to avoid blank screenshots.
# PYVISTA_OFF_SCREEN=true is *NOT* needed
ENV \
    MNE_3D_BACKEND=pyvista \
    MNE_3D_OPTION_ANTIALIAS=false\
    START_XVFB=true

ENTRYPOINT ["tini", "-g", "--", "/usr/bin/prepare.sh"]
