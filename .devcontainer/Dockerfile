ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# Install required tools
RUN apt-get update && apt-get install -y gnupg curl

# Add MiKTeX GPG key
RUN curl -fsSL https://miktex.org/download/key | apt-key add -

# Add MiKTeX repository for Ubuntu 22.04
RUN echo "deb https://miktex.org/download/ubuntu jammy universe" > /etc/apt/sources.list.d/miktex.list

# Install MiKTeX
RUN apt-get update && apt-get install -y miktex

# Finish MiKTeX setup
RUN miktexsetup --shared=yes finish && \
    initexmf --admin --set-config-value [MPM]AutoInstall=1
