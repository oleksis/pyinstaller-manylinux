FROM quay.io/pypa/manylinux_2_28_x86_64 AS compile-image

LABEL maintainer="Oleksis Fraga <oleksis.fraga at gmail.com>"
LABEL org.opencontainers.image.source=https://github.com/oleksis/pyinstaller-manylinux
LABEL org.opencontainers.image.description="Run PyInstaller on ManyLinux 2.28 (AlmaLinux 8.7 based) using Pyenv"
LABEL org.opencontainers.image.licenses=MIT

SHELL ["/bin/bash", "-c"]

ARG HOME=/root
ARG PYTHON_VERSION=3.8
ARG PYTHON_LAST=3.8.15
ARG PYINSTALLER_VERSION=5.6.2
ARG OPENSSL_VERSION=openssl-1.1.1s
ARG OPENSSL_DIR=/usr/local/ssl
ARG UPX_VERSION=4.0.1
ARG UPX_FILE=upx-${UPX_VERSION}-amd64_linux

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
ENV HOME=${HOME}
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV PYTHON_LAST=${PYTHON_LAST}
ENV PYINSTALLER_VERSION=${PYINSTALLER_VERSION}
# ENV PY38_BIN=/opt/_internal/cpython-3.8.15/bin
# Ensure we use PY38 in the PATH
# ENV PATH="${PY38_BIN}:$PATH"
ENV OPENSSL_VERSION=${OPENSSL_VERSION}
ENV OPENSSL_DIR=${OPENSSL_DIR}
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV UPX_VERSION=${UPX_VERSION}
ENV UPX_FILE=${UPX_FILE}

# Python Devel binary dependencies on AlmaLinux 8.7 (Stone Smilodon)"
# Requirement for install Python from source (Build dependencies)
RUN \
    set -exuo pipefail \
    && dnf -y install --allowerasing make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
#    openssl-devel \
    tk-devel libffi-devel xz-devel libuuid-devel gdbm-devel libnsl2-devel \
    && dnf clean all \
    && rm -rf /var/cache/yum

# UPX
RUN \
    set -exuo pipefail \ 
    && curl -s -L -o ${UPX_FILE}.tar.xz https://github.com/upx/upx/releases/download/v${UPX_VERSION}/${UPX_FILE}.tar.xz \
    && tar -xf ${UPX_FILE}.tar.xz -C /opt \
    && rm -rf ${UPX_FILE}.tar.xz
    
# OpenSSL
RUN \
    set -exuo pipefail \
    && yum erase -y openssl-devel \
    && curl -s -L -o ${OPENSSL_VERSION}.tar.gz https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz \
    && tar -xzf ${OPENSSL_VERSION}.tar.gz \
    && pushd ${OPENSSL_VERSION} \
    && ./config --prefix=${OPENSSL_DIR} --openssldir=${OPENSSL_DIR} shared zlib > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && popd \
    && rm -rf ${OPENSSL_VERSION} ${OPENSSL_VERSION}.tar.gz \
    && ${OPENSSL_DIR}/bin/openssl version

ENV PATH="${HOME}/.pyenv/bin:${OPENSSL_DIR}:/opt/${UPX_FILE}:$PATH"

# Pyenv
RUN \
    set -x \
    && touch ${HOME}/.bashrc \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.bashrc \
    && echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ${HOME}/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> ${HOME}/.bashrc \
    && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && source ${HOME}/.bashrc \
    && CPPFLAGS="-O2 -I${OPENSSL_DIR}/include" CFLAGS="-I${OPENSSL_DIR}/include" \
       LD_FLAGS="-L${OPENSSL_DIR}/lib -Wl,-rpath,${OPENSSL_DIR}/lib" LD_RUN_PATH="${OPENSSL_DIR}/lib" \
       CONFIGURE_OPTS="--with-openssl=${OPENSSL_DIR}" PYTHON_CONFIGURE_OPTS="--enable-shared" \
       pyenv install ${PYTHON_LAST} \
    && pyenv global ${PYTHON_LAST} \
    && pyenv exec pip install --upgrade pip setuptools wheel \
    && pyenv exec pip install --upgrade pyinstaller==$PYINSTALLER_VERSION

COPY pyinstaller-entrypoint.sh /usr/local/bin/pyinstaller-entrypoint.sh

RUN \
    set -x \
    && mkdir -p /src/ \
    && chmod +x /usr/local/bin/pyinstaller-entrypoint.sh

VOLUME /src/
# WORKDIR /src/

ENTRYPOINT ["pyinstaller-entrypoint.sh"]
