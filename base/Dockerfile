FROM mambaorg/micromamba:2.9.0-ubuntu26.04

# MNE-Python version: a release tag like v1.13.2 is installed from conda-forge,
# anything else (e.g., main) is pip-installed from that GitHub ref
ARG mne_v=v1.13.2

LABEL org.opencontainers.image.source="https://github.com/mne-tools/mne-docker" \
      org.opencontainers.image.description="MNE-Python with its scientific Python dependencies" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.version="${mne_v}"

ENV DEBIAN_FRONTEND=noninteractive

ARG MNE_USER="mne_user"
ARG HOME_DIR="/home/${MNE_USER}"
ENV MNE_USER=${MNE_USER}
ENV HOME_DIR=${HOME_DIR}

USER root

# git for users and pip installs from GitHub, sudo so prepare.sh can install EXTRA_APT_PACKAGES
RUN apt-get update && \
    apt-get install -y --no-install-recommends git sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Rename the micromamba user to mne_user, keeping the UID/GID the Ubuntu-based images used
# https://micromamba-docker.readthedocs.io/en/latest/advanced_usage.html#changing-the-user-id-or-name
RUN usermod --login=${MNE_USER} --home=${HOME_DIR} --move-home -u 1001 ${MAMBA_USER} && \
    groupmod --new-name=${MNE_USER} -g 1001 ${MAMBA_USER} && \
    echo "${MNE_USER}" > /etc/arg_mamba_user && \
    echo "${MNE_USER} ALL=(root) NOPASSWD: /usr/bin/apt-get" > /etc/sudoers.d/${MNE_USER} && \
    chmod 0440 /etc/sudoers.d/${MNE_USER} && \
    printf "channels:\n  - conda-forge\nchannel_priority: strict\n" > ${MAMBA_ROOT_PREFIX}/.condarc
ENV MAMBA_USER=${MNE_USER}

COPY prepare.sh /usr/bin/prepare.sh
COPY cleanup.sh /usr/bin/cleanup.sh
RUN chmod a+x /usr/bin/prepare.sh /usr/bin/cleanup.sh

USER $MNE_USER
WORKDIR $HOME_DIR

# Make the environment available to RUN steps and "docker exec", not just the entrypoint
ENV PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"

RUN if [[ "${mne_v}" =~ ^v[0-9] ]]; then mne_spec="mne-base=${mne_v#v}"; else mne_spec="mne-base"; fi && \
    micromamba install -y -n base \
        python=3.14 \
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
        mne-bids-pipeline \
        statsmodels \
        fooof \
        "${mne_spec}" && \
    if [[ ! "${mne_v}" =~ ^v[0-9] ]]; then \
        pip install --no-cache-dir "https://github.com/mne-tools/mne-python/archive/${mne_v}.zip"; \
    fi && \
    cleanup.sh && \
    micromamba list

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "tini", "-g", "--", "/usr/bin/prepare.sh"]
CMD ["/bin/bash"]
