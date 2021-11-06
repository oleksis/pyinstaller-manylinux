#!/bin/bash
# From https://github.com/cdrx/docker-pyinstaller/blob/master/entrypoint-linux.sh

# Fail on errors.
set -e

# Adapted Environment variable HOME for GitHub Actions
HOME=/root

if [ -z "$GITHUB_WORKSPACE" ]; then
    WORKDIR="."
else
    WORKDIR=$GITHUB_WORKSPACE
fi

#
# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.
#
if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    # the funky looking regexp just extracts the hostname, excluding port
    # to be used as a trusted-host.
    mkdir -p $HOME/.pip
    echo "[global]" > $HOME/.pip/pip.conf
    echo "index = $PYPI_URL" >> $HOME/.pip/pip.conf
    echo "index-url = $PYPI_INDEX_URL" >> $HOME/.pip/pip.conf
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> $HOME/.pip/pip.conf

    echo "Using custom pip.conf: "
    cat $HOME/.pip/pip.conf
fi

cd $WORKDIR

# Run setup.sh pre requirements (like pre-if metadata syntax for GitHub Action)
if [ -f setup.sh ]; then
    chmod +x ./setup.sh
    ./setup.sh
fi # [ -f setup.sh ]

# Install requirements
if [ -f requirements.txt ]; then
    pyenv exec pip install -r requirements.txt
fi # [ -f requirements.txt ]

# Source ~/.bashrc
source $HOME/.bashrc

echo "PyInstaller parameters: $@"

pyenv exec pyinstaller --clean -y --dist ./dist "$@"
chown -R --reference=. ./dist
