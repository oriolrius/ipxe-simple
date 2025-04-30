FROM ubuntu:22.04

LABEL maintainer="Alexander Sorokin <sebastian.sorokin@gmail.com>"
LABEL description="Build environment with necessary tools and scripts."

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Update apt cache, install build dependencies and git in a single layer
# Use --no-install-recommends to minimize image size
# Clean up apt cache afterwards to reduce layer size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    gcc \
    binutils \
    make \
    perl \
    liblzma-dev \
    libc6-dev \
    isolinux \
    syslinux \
    xorriso \
    mtools \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for subsequent instructions
# Using a dedicated directory like /app is better practice than using /
WORKDIR /

# Copy configuration and scripts into the working directory
# Ensure these files exist in the build context (same directory as Dockerfile)
COPY config-backup ./config-backup
COPY renew.sh ./

# Make the script executable
RUN chmod +x ./renew.sh

RUN mkdir /builds
RUN mkdir /ipxe
