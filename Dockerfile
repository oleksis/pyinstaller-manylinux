FROM quay.io/pypa/manylinux2014_x86_64 AS compile-image

LABEL maintainer="Oleksis Fraga <oleksis.fraga at gmail.com>"

SHELL ["/bin/bash", "-i", "-c"]

ARG PYTHON_VERSION=3
ARG PYINSTALLER_VERSION=3.6

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
# ManyLinux 2014 use Python 3.6 by default
ENV PYTHON_VERSION=3
ENV PYINSTALLER_VERSION=${PYINSTALLER_VERSION}
# ENV PY37_BIN=/opt/python/cp37-cp37m/bin
# Ensure we use PY37 in the PATH
# ENV PATH="$PY37_BIN:$PATH"

# Python Devel binary dependencies on Centos 7
RUN \
    yum -y install yum-utils \
    && yum -y update \
    && yum -y group install development \
	&& yum -y install python3 python3-tools python3-devel python3-virtualenv

RUN \
    set -x \
    && python$PYTHON_VERSION -m pip install --upgrade pip setuptools wheel \
    && pip$PYTHON_VERSION install pyinstaller==$PYINSTALLER_VERSION

COPY entrypoint.sh /entrypoint.sh
RUN \
    set -x \
    && mkdir -p /src/ \
    && chmod +x /entrypoint.sh

VOLUME /src/
# WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]
