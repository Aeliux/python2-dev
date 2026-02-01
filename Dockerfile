# syntax=docker/dockerfile:1

# Python 2.7.18 Development Environment
#
# Multi-stage build for optimized Python 2.7.18 development environment
# Based on Debian with CPython compiled from source

# Build stage: compile CPython 2.7.18 from source
ARG DEBIAN_VERSION=trixie
FROM debian:${DEBIAN_VERSION}-slim AS builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install build dependencies
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -yq --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libncurses5-dev \
    liblzma-dev \
    pkg-config \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

# Download and verify Python 2.7.18 source code
WORKDIR /usr/src
RUN wget -q https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz \
    && echo "da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814 Python-2.7.18.tgz" | sha256sum -c - \
    && tar xf Python-2.7.18.tgz \
    && rm Python-2.7.18.tgz

# Build and install Python 2.7.18
WORKDIR /usr/src/Python-2.7.18
RUN ./configure \
    --prefix=/usr/local \
    --enable-shared \
    --enable-unicode=ucs4 \
    --with-ensurepip=install \
    --enable-optimizations \
    --without-tk \
    --disable-test-modules \
    LDFLAGS="-Wl,-rpath=/usr/local/lib" \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig

# Upgrade pip, setuptools, and wheel, and install additional Python packages
COPY requirements.txt /tmp/
RUN /usr/local/bin/python2 -m pip install --disable-pip-version-check --no-cache-dir --upgrade \
    pip==20.3.4 \
    setuptools==44.1.1 \
    wheel==0.37.1 \
    && /usr/local/bin/python2 -m pip install --disable-pip-version-check --no-cache-dir -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

# Download and verify Python 3.12 source code
WORKDIR /usr/src
RUN wget -q https://www.python.org/ftp/python/3.12.8/Python-3.12.8.tgz \
    && echo "5cbdb4749c770cebf94618ad0112a4082409712b99bf1fb20a5e5bf9ed24e0d3 Python-3.12.8.tgz" | sha256sum -c - \
    && tar xf Python-3.12.8.tgz \
    && rm Python-3.12.8.tgz

# Build and install Python 3.12
WORKDIR /usr/src/Python-3.12.8
RUN ./configure \
    --prefix=/opt/python3 \
    --enable-shared \
    --enable-optimizations \
    --with-lto \
    --with-computed-gotos \
    --with-ensurepip=install \
    --without-tkinter \
    --disable-test-modules \
    LDFLAGS="-Wl,-rpath=/opt/python3/lib" \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig

# Install Python 3 requirements
COPY requirements3.txt /tmp/
RUN /opt/python3/bin/python3 -m pip install --disable-pip-version-check --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel \
    && /opt/python3/bin/python3 -m pip install --disable-pip-version-check --no-cache-dir -r /tmp/requirements3.txt \
    && rm -f /tmp/requirements3.txt

# Optimize and cleanup all Python installations
RUN find /usr/local /opt/python3 -type f -name '*.pyc' -delete \
    && find /usr/local /opt/python3 -type f -name '*.pyo' -delete \
    && find /usr/local /opt/python3 -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local /opt/python3 -type d -name 'test' -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local /opt/python3 -type d -name 'tests' -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local /opt/python3 -type f -name '*.so*' -exec strip --strip-unneeded {} + 2>/dev/null || true \
    && find /usr/local /opt/python3 -type f -executable -exec strip --strip-unneeded {} + 2>/dev/null || true \
    && rm -rf /usr/src/*

# Runtime stage: minimal development environment
ARG DEBIAN_VERSION=trixie
FROM debian:${DEBIAN_VERSION}-slim AS runtime
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install runtime dependencies and common development tools
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -yq --no-install-recommends \
    ca-certificates \
    libssl3t64 \
    zlib1g \
    libbz2-1.0 \
    libreadline8t64 \
    libsqlite3-0 \
    libffi8 \
    libncurses6 \
    liblzma5 \
    git \
    curl \
    nano \
    wget \
    vim-tiny \
    less \
    procps \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy Python installations from builder
COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt/python3 /opt/python3

# Configure dynamic linker for shared libraries
RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/python2.conf \
    && echo '/opt/python3/lib' > /etc/ld.so.conf.d/python3.conf \
    && ldconfig

# Create symlinks for python commands
RUN ln -sf /usr/local/bin/python2 /usr/local/bin/python \
    && ln -sf /usr/local/bin/python2.7 /usr/local/bin/python2 \
    && ln -sf /opt/python3/bin/python3 /usr/local/bin/python3 \
    && ln -sf /opt/python3/bin/python3.12 /usr/local/bin/python3.12 \
    && ln -sf /opt/python3/bin/pip3 /usr/local/bin/pip3

# Set environment variables
ENV PYTHON_VERSION=2.7.18 \
    PYTHON3_VERSION=3.12.8 \
    PATH="/opt/python3/bin:${PATH}" \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_PYTHON_VERSION_WARNING=1 \
    PIP_ROOT_USER_ACTION=ignore \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Create a non-root user with id 1000 and add it to sudoers
RUN useradd -m -u 1000 python \
    && echo 'python ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/python \
    && chmod 0440 /etc/sudoers.d/python

USER python

# Enable python2 support for mypy
COPY mypy.ini /home/python/.mypy.ini

CMD ["/bin/bash"]
