FROM quay.io/pypa/manylinux_2_24_x86_64 AS compile-image

LABEL maintainer="Oleksis Fraga <oleksis.fraga at gmail.com>"

SHELL ["/bin/bash", "-i", "-c"]

ARG PYTHON_VERSION=3.6
ARG PYINSTALLER_VERSION=3.6

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
# ManyLinux 2.24 use Python 3.5 by default
# we use Python 3.6
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV PYINSTALLER_VERSION=${PYINSTALLER_VERSION}
# ENV PY37_BIN=/opt/python/cp37-cp37m/bin
# Ensure we use PY37 in the PATH
# ENV PATH="$PY37_BIN:$PATH"

# Python Devel binary dependencies on Debian 9
RUN \
    apt-get update \
    && apt-get install -y build-essential dpkg-dev

# Update Alternatives for Python
RUN \
    update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 \
    && update-alternatives --install /usr/bin/python python /opt/_internal/cpython-3.6.15/bin/python3.6 2

RUN \
    set -x \
    && python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install --upgrade pyinstaller==$PYINSTALLER_VERSION

COPY entrypoint.sh /entrypoint.sh

RUN \
    set -x \
    && mkdir -p /src/ \
    && chmod +x /entrypoint.sh

RUN \
    alias pyinstaller='pyhton -m pyinstaller'

VOLUME /src/
# WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]
