FROM mambaorg/micromamba:1-noble

ARG mne_v=v1.8.0

ENV DEBIAN_FRONTEND=noninteractive

ARG MNE_USER="mne_user"
ARG HOME_DIR="/home/${MNE_USER}"
ENV MNE_USER=${MNE_USER}
ENV HOME_DIR=${HOME_DIR}

# setup entry point
COPY prepare.sh /usr/bin/prepare.sh
RUN sudo chmod a+x /usr/bin/prepare.sh

RUN chmod 777 /opt

# setup mne user
RUN useradd -ms /bin/bash -d ${HOME_DIR} ${MNE_USER}
USER $MNE_USER
WORKDIR $HOME_DIR

# setup conda
RUN micromamba config append channels conda-forge && \
    micromamba config set channel_priority strict && \
    micromamba shell init -s bash && \
    echo "micromamba activate" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]
RUN conda install --yes \
    -c conda-forge \
    python==3.12 \
    python-blosc \
    cytoolz \
    dask \
    lz4 \
    nomkl \
    numpy \
    pandas \
    tini \
    pooch \
    bokeh \
    joblib \
    nibabel \
    h5py \
    s3fs \
    matplotlib-base \
    scikit-learn \
    numba \
    nilearn \
    dipy \
    h5io \
    && conda clean -tipy

RUN pip install https://github.com/mne-tools/mne-python/archive/${mne_v}.zip

ENTRYPOINT ["tini", "-g", "--", "/usr/bin/prepare.sh"]
