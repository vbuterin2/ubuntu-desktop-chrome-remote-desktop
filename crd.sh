#!/bin/bash -x
#
# This script should only be used in ubuntu

function install_desktop_env {
  PACKAGES="desktop-base xscreensaver"

  if [[ "$INSTALL_XFCE" = "yes" ]] ; then
    PACKAGES="$PACKAGES xfce4"
    echo "exec xfce4-session" > /etc/chrome-remote-desktop-session
#     [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
#       PACKAGES="$PACKAGES task-xfce-desktop"
  fi
  
  if [[ "$INSTALL_UBUNTU" = "yes" ]] ; then
    PACKAGES="$PACKAGES ubuntu-desktop"
    echo "export GNOME_SHELL_SESSION_MODE=ubuntu" > /etc/chrome-remote-desktop-session
    echo "exec /etc/X11/Xsession /usr/bin/gnome-session" >> /etc/chrome-remote-desktop-session
  fi

  if [[ "$INSTALL_CINNAMON" = "yes" ]] ; then
    PACKAGES="$PACKAGES cinnamon-core"
    echo "exec cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session
#     [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
#       PACKAGES="$PACKAGES task-cinnamon-desktop"
  fi

  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES $EXTRA_PACKAGES

  systemctl disable lightdm.service
}

function download_and_install { # args URL FILENAME
  curl -L -o "$2" "$1"
  dpkg --install "$2"
  apt-get install --assume-yes --fix-broken
}

function is_installed {  # args PACKAGE_NAME
  dpkg-query --list "$1" | grep -q "^ii" 2>/dev/null
  return $?
}

# Configure the following environmental variables as required:
INSTALL_XFCE=yes
INSTALL_CINNAMON=no
INSTALL_UBUNTU=no
INSTALL_CHROME=yes
INSTALL_FULL_DESKTOP=yes

# Any additional packages that should be installed on startup can be added here
EXTRA_PACKAGES="less bzip2 zip unzip"

apt-get update

! is_installed chrome-remote-desktop && \
  download_and_install \
    https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
    /tmp/chrome-remote-desktop_current_amd64.deb

install_desktop_env

[[ "$INSTALL_CHROME" = "yes" ]] && \
  ! is_installed google-chrome-stable && \
  download_and_install \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    /tmp/google-chrome-stable_current_amd64.deb

echo "Chrome remote desktop installation completed"
