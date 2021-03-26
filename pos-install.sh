#!/usr/bin/env sh

# source config.sh
source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-dev/master/_common.sh)

# XFCE
xfce=(
  "xfce4"
  "xfce4-goodies"
  "file-roller"
  "xfce4-whiskermenu-plugin"
  "alacarte"
  "thunar-volman"
  "thunar-archive-plugin"
  "xfce4-dockbarx-plugin"
  "xfce-theme-greybird"
  "elementary-xfce-icons"
  "mugshot"
  "galculator"
  "pavucontrol"
  "gnome-keyring"
  "xfce-polkit-git"
  "lightdm"
  "lightdm-gtk-greeter"
  "lightdm-gtk-greeter-settings"
  "light-locker"
)

# Gnome
gnome=(
  "gnome"
  "gnome-terminal"
  "gdm"
  "gnome-tweaks"
  "nautilus"
  "nautilus-sendto"
  "gnome-usage"
  "chrome-gnome-shell"
  "xdg-user-dirs-gtk"
  "fwupd"
  "seahorse"
)

extra=(
  "google-chrome"
  "libreoffice-fresh"
  "libreoffice-fresh-pt-br"
  "pamac-aur-tray-appindicator-git"
  "telegram-desktop"
  "virtualbox-host-dkms"
  "virtualbox"
)

clear
install_pkg $gnome
install_pkg $extra
