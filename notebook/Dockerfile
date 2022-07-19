FROM jupyter/base-notebook:lab-2.2.5

USER root

RUN apt-get update \
    && apt-get install -yq --no-install-recommends graphviz git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
    openssh-client \
    vim \
    curl \
    gcc \
    && apt-get clean

# Xvfb
RUN apt-get install -yq --no-install-recommends \
    xvfb \
    x11-utils \
    libx11-dev \
    qt5-default \
    && apt-get clean

ENV DISPLAY=:99

USER $NB_USER

# Upgrade the package managers
RUN pip install --upgrade pip
RUN npm i npm@latest -g

RUN conda install --yes \
    -c conda-forge \
    python-blosc \
    cytoolz \
    dask==2020.12.0 \
    lz4 \
    nomkl \
    numpy==1.18.1 \
    pandas==1.0.1 \
    ipywidgets \
    dask-labextension==3.0.0 \
    python-graphviz \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager dask-labextension@3.0.0 \
    && conda clean -tipy \
    && jupyter lab clean \
    && jlpm cache clean \
    && npm cache clean --force \
    && find /opt/conda/ -type f,l -name '*.a' -delete \
    && find /opt/conda/ -type f,l -name '*.pyc' -delete \
    && find /opt/conda/ -type f,l -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -type f,l -name '*.js' -not -name '*.min.js' -delete \
    && rm -rf /opt/conda/pkgs


# Install Python packages
RUN pip install vtk && \
    pip install boto && \
    pip install h5py && \
    pip install nose && \
    pip install ipyevents && \
    pip install ipywidgets && \
    pip install mayavi && \
    pip install nibabel && \
    pip install numpy && \
    pip install pillow && \
    pip install pyqt5 && \
    pip install scikit-learn && \
    pip install scipy && \
    pip install xvfbwrapper && \
    pip install https://github.com/nipy/PySurfer/archive/master.zip && \
    pip install https://codeload.github.com/mne-tools/mne-python/zip/master

# Install Jupyter notebook extensions
RUN pip install RISE && \
    jupyter nbextension install rise --py --sys-prefix && \
    jupyter nbextension enable rise --py --sys-prefix && \
    jupyter nbextension install mayavi --py --sys-prefix && \
    jupyter nbextension enable mayavi --py --sys-prefix && \
    npm cache clean --force

# Download the MNE-sample dataset
RUN ipython -c "import mne; print(mne.datasets.sample.data_path(verbose=False))"

# Try to decrease initial IPython kernel load times
RUN ipython -c "import matplotlib.pyplot as plt; print(plt)"

# Download and move ipynb notebooks
RUN git clone --depth=1 https://github.com/mne-tools/mne-tools.github.io && \
    mv mne-tools.github.io/dev/_downloads/*/*.ipynb . && \
    rm -Rf mne-tools.github.io

# Configure the MNE raw browser window to use the full width of the notebook
RUN ipython -c "import mne; mne.set_config('MNE_BROWSE_RAW_SIZE', '9.8, 7')"

# Add an x-server to the entrypoint. This is needed by Mayavi
ENTRYPOINT ["tini", "-g", "--", "xvfb-run"]
