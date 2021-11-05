FROM quay.io/pypa/manylinux_2_24_x86_64 AS compile-image

LABEL maintainer="Oleksis Fraga <oleksis.fraga at gmail.com>"

SHELL ["/bin/bash", "-c"]

ARG HOME=/root
ARG PYTHON_VERSION=3.6
ARG PYTHON_LAST=3.6.15
ARG PYINSTALLER_VERSION=3.6
ARG OPENSSL_DIR=/usr/local/ssl


ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
# ManyLinux 2.24 use Python 3.5 by default
# we use Python 3.6
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV PYTHON_LAST=${PYTHON_LAST}
ENV PYINSTALLER_VERSION=${PYINSTALLER_VERSION}
# ENV PY36_BIN=/opt/_internal/cpython-3.6.15/bin
# Ensure we use PY36 in the PATH
# ENV PATH="${PY36_BIN}:$PATH"

ENV OPENSSL_DIR=${OPENSSL_DIR}
ENV PYENV_ROOT="${HOME}/.pyenv"

# Python Devel binary dependencies on Debian 9
# Requirement for install Python from source (Build dependencies)
RUN \
    apt-get update \
    && apt-get install -y make checkinstall build-essential \
    dpkg-dev libreadline-dev libncursesw5-dev libbz2-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev \
    libffi-dev zlib1g-dev curl llvm xz-utils \
    libxml2-dev libxmlsec1-dev liblzma-dev \
    git wget upx ca-certificates

# openssl 1.1.1
RUN \
    set -x \
    && apt-get -y remove libssl-dev \
    && wget -q https://www.openssl.org/source/openssl-1.1.1.tar.gz \
    && tar -xzf openssl-1.1.1.tar.gz \
    && pushd openssl-1.1.1 \
    && ./config --prefix=${OPENSSL_DIR} --openssldir=${OPENSSL_DIR} shared zlib \
    && make \
    && make install \
    && popd

ENV LD_LIBRARY_PATH=${OPENSSL_DIR}/lib
ENV PATH="${HOME}/.pyenv/bin:${OPENSSL_DIR}:$PATH"

# Pyenv
RUN \
    set -x \
    && touch ${HOME}/.bashrc \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.bashrc \
    && echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ${HOME}/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> ${HOME}/.bashrc \
    && echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc \
    && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && source ${HOME}/.bashrc \
    && CPPFLAGS="-O2 -I${OPENSSL_DIR}/include" CFLAGS="-I${OPENSSL_DIR}/include" \
       LD_FLAGS="-L${OPENSSL_DIR}/lib -Wl,-rpath,${OPENSSL_DIR}/lib" LD_RUN_PATH="${OPENSSL_DIR}/lib" \
       CONFIGURE_OPTS="--with-openssl=${OPENSSL_DIR}" PYTHON_CONFIGURE_OPTS="--enable-shared" \
       pyenv install ${PYTHON_LAST} \
    && pyenv global ${PYTHON_LAST} \
    && pyenv exec pip install --upgrade pip setuptools wheel \
    && pyenv exec pip install --upgrade pyinstaller==$PYINSTALLER_VERSION

COPY entrypoint.sh /entrypoint.sh

RUN \
    set -x \
    && mkdir -p /src/ \
    && chmod +x /entrypoint.sh

VOLUME /src/
# WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]
