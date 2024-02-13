FROM ubuntu:22.04

ARG ENTRYPOINT

# Set environment variables
ENV USER steamcmd
ENV UID 1000
ENV HOME /home/$USER

COPY $ENTRYPOINT /usr/local/bin/entrypoint.sh

# 创建用户和组
RUN set -xe \
    && groupadd --gid $UID $USER \
    && useradd --uid $UID --gid $UID -m $USER \
    && apt-get update -y \
    && apt-get install -y sudo \
    && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER \
    && rm -rf /var/lib/apt/lists/*

USER $USER

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -xe \
    && echo steam steam/question select "I AGREE" | sudo debconf-set-selections \
    && echo steam steam/license note '' | sudo debconf-set-selections

# Update the repository and install SteamCMD and deps
ARG DEBIAN_FRONTEND=noninteractive
RUN set -xe \
    && sudo dpkg --add-architecture i386 \
    && sudo apt-get update -y \
    && sudo apt-get install -y --no-install-recommends \
    ca-certificates \
    locales \
    steamcmd \
    xdg-user-dirs \
    tzdata \
    && sudo rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN sudo locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Create symlink for executable
RUN sudo ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Set working directory
WORKDIR $HOME

# Update SteamCMD and verify latest version
RUN set -xe \
    && mkdir -p $HOME/.steam \
    && steamcmd +quit

# Fix missing directories and libraries
RUN set -xe \
    && mkdir steamapps \
    && ln -s $HOME/steamapps $HOME/.local/share/Steam/steamcmd/steamapps \
    && ln -s $HOME/.local/share/Steam/steamcmd/linux32 $HOME/.steam/sdk32 \
    && ln -s $HOME/.local/share/Steam/steamcmd/linux64 $HOME/.steam/sdk64 \
    && ln -s $HOME/.steam/sdk32/steamclient.so $HOME/.steam/sdk32/steamservice.so \
    && ln -s $HOME/.steam/sdk64/steamclient.so $HOME/.steam/sdk64/steamservice.so

ENTRYPOINT [ "entrypoint.sh" ]
