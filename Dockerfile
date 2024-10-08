# Debian 12.6
FROM debian:bookworm-20240722

ARG user_name=developer
ARG user_id
ARG group_id
ARG dotfiles_repository="https://github.com/uraitakahito/dotfiles.git"

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# Install packages
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    # Basic
    iputils-ping \
    # Editor
    vim emacs \
    # Utility
    tmux \
    # fzf needs PAGER(less or something)
    fzf \
    trash-cli && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# eza
# https://github.com/eza-community/eza/blob/main/INSTALL.md
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    gpg \
    wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /etc/apt/keyrings && \
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list && \
  chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list && \
  apt update && \
  apt install -y eza && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# Desktop
#
# Install XFCE, VNC server, dbus-x11, and xfonts-base
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    xfonts-base && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# VNC
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    tigervnc-standalone-server \
    tigervnc-tools \
    tigervnc-common && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
# Set display resolution
ENV RESOLUTION=1280x1024
# Copy a script to start the VNC server
COPY start-vnc.sh /bin/start-vnc.sh
RUN chmod +x /bin/start-vnc.sh

#
# noVNC
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    novnc \
    websockify && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
EXPOSE 6080

#
# Firefox
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    firefox-esr \
    firefox-esr-l10n-ja \
    fonts-noto-cjk \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/

#
# Add user and install basic tools.
#
RUN cd /usr/src && \
  git clone --depth 1 https://github.com/uraitakahito/features.git && \
  USERNAME=${user_name} \
  USERUID=${user_id} \
  USERGID=${group_id} \
  CONFIGUREZSHASDEFAULTSHELL=true \
    /usr/src/features/src/common-utils/install.sh
USER ${user_name}

#
# Setup VNC server
#
RUN mkdir /home/${user_name}/.vnc \
    && echo "password" | vncpasswd -f > /home/${user_name}/.vnc/passwd \
    && chmod 600 /home/${user_name}/.vnc/passwd

#
# Create an .Xauthority file
#
RUN touch /home/${user_name}/.Xauthority

#
# dotfiles
#
RUN cd /home/${user_name} && \
  git clone --depth 1 ${dotfiles_repository} && \
  dotfiles/install.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-F", "/dev/null"]
