#!/bin/bash

set -x

# We start by adding extra apt packages, since pip modules may required library
if [ "$EXTRA_APT_PACKAGES" ]; then
    echo "EXTRA_APT_PACKAGES environment variable found.  Installing."
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends $EXTRA_APT_PACKAGES
fi

if [ -e "/opt/app/environment.yml" ]; then
    echo "environment.yml found. Installing packages"
    micromamba install -y -n base -f /opt/app/environment.yml
else
    echo "no environment.yml"
fi

if [ "$EXTRA_CONDA_PACKAGES" ]; then
    echo "EXTRA_CONDA_PACKAGES environment variable found.  Installing."
    micromamba install -y -n base $EXTRA_CONDA_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing".
    pip install $EXTRA_PIP_PACKAGES
fi

if [ "$START_XVFB" ]; then
    /sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_99.pid \
        --make-pidfile --background --exec /usr/bin/Xvfb -- :99 \
        -screen 0 1400x900x24 -ac +extension GLX +render -noreset
    sleep 3
    export DISPLAY=:99
fi

# Run extra commands
exec "$@"
