#!/bin/bash -x
#
# This script should only be used in ubuntu

function install_unagi {
  PACKAGES="unagi"


  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES

  echo "unagi screen compositor installation completed."
}

function add_swap_space {
   sudo fallocate -l $SWAP_SPACE $SWAP_LOCATION
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   sudo cp /etc/fstab /etc/fstab.bak

   free -h

   echo "Swap space of $SWAP_SPACE added at $SWAP_LOCATION. "

}


function install_visual_studio_code {
  sudo snap install code --classic
}

function install_oh_my_zsh {
  PACKAGES="git zsh curl wget"
  
  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES
    
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  
  echo "oh my zsh installation complete."
  
}

function install_office_tools {
  PAKCAGES="libreoffice"
  
  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES
    
  echo "Office tools installation complete."
} 

function install_fonts {
  PACKAGES="fonts-wqy-microhei"
  
  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES
    
  echo "CN Fonts installation complete."
} 
  

function install_im_tools {
  PACKAGES="telegram-desktop"
  
  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES
    
  echo "Common IM tools installation complete."
}

function install_essential_coding_tools {
  PACKAGES="terminator"
  
  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES
}

function install_desktop_env {
  PACKAGES="desktop-base xscreensaver"
  PACKAGES_TO_PURGE="man-db"

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
  
  # purge unnecessary and time consuming install steps

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
SWAP_SPACE=16G
SWAP_LOCATION=/swapfile

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

install_essential_coding_tools

echo "Essential tools installation completed"

install_im_tools

install_fonts

install_office_tools

install_oh_my_zsh

install_visual_studio_code

add_swap_space

install_unagi