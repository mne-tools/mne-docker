# TODO: Use micromamba instead of bare image at some point
FROM ubuntu:24.04

ARG mne_v=v1.8.0

ENV DEBIAN_FRONTEND=noninteractive

ARG MNE_USER="mne_user"
ARG HOME_DIR="/home/${MNE_USER}"
ENV MNE_USER=${MNE_USER}
ENV HOME_DIR=${HOME_DIR}

ARG MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX}

# install xvfb
RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y --no-install-recommends git && \
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

# setup conda via micromamba
# https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html#automatic-install
ENV PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"
ARG PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"
ENV SHELL="/bin/bash"
RUN wget https://micro.mamba.pm/install.sh && \
    sh ./install.sh && \
    rm -f ./install.sh
SHELL ["/bin/bash", "--login", "-c"]
RUN micromamba shell init -s bash -r ${MAMBA_ROOT_PREFIX}
RUN echo "micromamba activate" | tee -a ~/.bashrc
RUN cat ~/.bashrc
RUN echo "PATH=$PATH"
RUN which micromamba && \
    micromamba config append channels conda-forge && \
    micromamba config set channel_priority strict && \
    micromamba config list --sources
RUN micromamba install -y \
    python=3.13 \
    conda \
    mamba \
    conda-libmamba-solver

RUN which conda && \
    conda --version && \
    which mamba && \
    mamba --version

RUN conda clean -tipy
RUN find /opt/conda/ -type f,l -name '*.a' -delete
RUN find /opt/conda/ -type f,l -name '*.pyc' -delete
RUN find /opt/conda/ -type f,l -name '*.js.map' -delete
RUN rm -rf /opt/conda/pkgs

RUN conda list

RUN pip install https://github.com/mne-tools/mne-python/archive/${mne_v}.zip

ENTRYPOINT ["tini", "-g", "--", "/usr/bin/prepare.sh"]
