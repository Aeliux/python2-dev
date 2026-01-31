# syntax=docker/dockerfile:1
# =============================================================================
# Python 2.7.18 Development Environment
# =============================================================================
# Multi-stage build for optimized Python 2.7.18 development environment
# Based on Debian with CPython compiled from source
# =============================================================================

# Build argument for Debian version
ARG DEBIAN_VERSION=trixie

# Build stage: compile CPython 2.7.18 from source
FROM debian:${DEBIAN_VERSION}-slim AS builder

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install build dependencies
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -yq --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    # Library development headers
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libncurses5-dev \
    tk-dev \
    libgdbm-dev \
    liblzma-dev \
    # Build tools
    pkg-config \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

# Download and verify CPython 2.7.18 source
# SHA256: da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814
RUN wget -q https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz \
    && echo "da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814 Python-2.7.18.tgz" | sha256sum -c - \
    && tar xf Python-2.7.18.tgz \
    && rm Python-2.7.18.tgz

WORKDIR /usr/src/Python-2.7.18

# Configure and compile Python with optimizations
RUN ./configure \
    --prefix=/usr/local \
    --enable-shared \
    --enable-unicode=ucs4 \
    --with-ensurepip=install \
    --enable-optimizations \
    LDFLAGS="-Wl,-rpath=/usr/local/lib" \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig

# Upgrade pip, setuptools, and wheel
RUN /usr/local/bin/python2 -m pip install --disable-pip-version-check --no-cache-dir \
    --upgrade pip==20.3.4 setuptools==44.1.1 wheel==0.37.1

# Install Python packages from requirements.txt
COPY requirements.txt /tmp/
RUN /usr/local/bin/python2 -m pip install --disable-pip-version-check --no-cache-dir \
    -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

# Strip binaries and clean up to reduce size
RUN find /usr/local -type f -name '*.pyc' -delete \
    && find /usr/local -type f -name '*.pyo' -delete \
    && find /usr/local -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local -type f -name '*.so*' -exec strip --strip-unneeded {} + 2>/dev/null || true \
    && find /usr/local -type f -executable -exec strip --strip-unneeded {} + 2>/dev/null || true

# =============================================================================
# Runtime stage: minimal development environment
# =============================================================================
ARG DEBIAN_VERSION=trixie
FROM debian:${DEBIAN_VERSION}-slim AS runtime

# OCI standard metadata labels
LABEL org.opencontainers.image.title="Python 2.7.18 Development Environment" \
    org.opencontainers.image.description="Python 2.7.18 development environment built from source on Debian ${DEBIAN_VERSION}" \
    org.opencontainers.image.version="2.7.18" \
    org.opencontainers.image.authors="aeliux" \
    org.opencontainers.image.vendor="aeliux" \
    org.opencontainers.image.licenses="Python-2.0" \
    org.opencontainers.image.base.name="docker.io/library/debian:${DEBIAN_VERSION}-slim" \
    org.opencontainers.image.documentation="https://www.python.org/doc/versions/" \
    maintainer="aeliux"

# Additional informational labels
LABEL python.version="2.7.18" \
    python.architecture="x86_64" \
    debian.version="${DEBIAN_VERSION}"

# Set shell options
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install runtime dependencies and common development tools
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -yq --no-install-recommends \
    # SSL/TLS support
    ca-certificates \
    # Runtime libraries
    libssl3 \
    zlib1g \
    libbz2-1.0 \
    libreadline8 \
    libsqlite3-0 \
    libffi8 \
    libncurses6 \
    libgdbm6 \
    liblzma5 \
    # Development utilities
    git \
    curl \
    nano \
    wget \
    vim-tiny \
    less \
    procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy Python installation from builder
COPY --from=builder /usr/local /usr/local

# Configure dynamic linker for shared libraries
RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/python2.conf \
    && ldconfig

# Set Python environment variables
ENV PYTHON_VERSION=2.7.18 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_PYTHON_VERSION_WARNING=1 \
    PIP_ROOT_USER_ACTION=ignore \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Verify Python installation
RUN python2 --version \
    && pip --version

# Default command
CMD ["/bin/bash"]
