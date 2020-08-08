FROM quay.io/pypa/manylinux2014_x86_64 AS compile-image

LABEL maintainer="Oleksis Fraga <oleksis.fraga at gmail.com>"

SHELL ["/bin/bash", "-i", "-c"]

ARG PYTHON_VERSION=3
ARG PYINSTALLER_VERSION=3.6

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
# ManyLinux 2014 use Python 3.7
# ENV PYTHON_VERSION=3
ENV PYINSTALLER_VERSION=${PYINSTALLER_VERSION}

RUN \
    set -x \
    && pip install pyinstaller==$PYINSTALLER_VERSION

COPY entrypoint.sh /entrypoint.sh
RUN \
    set -x \
    && mkdir -p /src/ \
    && chmod +x /entrypoint.sh

VOLUME /src/
# WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]