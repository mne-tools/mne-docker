FROM ubuntu:20.04

ARG mne_v=v0.23.0

ENV DEBIAN_FRONTEND=noninteractive

ARG MNE_USER="mne_user"
ARG HOME_DIR="/home/${MNE_USER}"
ENV MNE_USER=${MNE_USER}
ENV HOME_DIR=${HOME_DIR}

ARG CONDA_DIR="/opt/conda/"

# install xvfb
RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setup entry point
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod a+x /usr/bin/prepare.sh

RUN chmod 777 /opt

# setup mne user
RUN useradd -ms /bin/bash -d ${HOME_DIR} ${MNE_USER}
USER $MNE_USER
WORKDIR $HOME_DIR

# setup conda
ENV PATH="${CONDA_DIR}/bin:${PATH}"
ARG PATH="${CONDA_DIR}/bin:${PATH}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh ./Miniconda3-latest-Linux-x86_64.sh -b -p ${CONDA_DIR} && \
    rm -f ./Miniconda3-latest-Linux-x86_64.sh && \
    conda init
SHELL ["/bin/bash", "--login", "-c"]

RUN conda install --yes \
    -c conda-forge \
    python==3.9 \
    python-blosc \
    cytoolz \
    dask==2021.4.0 \
    lz4 \
    nomkl \
    numpy==1.21.0 \
    pandas==1.3.0 \
    tini==0.18.0 \
    && conda clean -tipy \
    && find /opt/conda/ -type f,l -name '*.a' -delete \
    && find /opt/conda/ -type f,l -name '*.pyc' -delete \
    && find /opt/conda/ -type f,l -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -type f,l -name '*.js' -not -name '*.min.js' -delete \
    && rm -rf /opt/conda/pkgs

RUN pip install s3fs
RUN pip install bokeh
RUN pip install nibabel joblib h5py
RUN pip install pooch
RUN pip install https://github.com/mne-tools/mne-python/archive/${mne_v}.zip

ENTRYPOINT ["tini", "-g", "--", "/usr/bin/prepare.sh"]
