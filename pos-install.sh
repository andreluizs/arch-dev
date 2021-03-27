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

# Gnome Packages
gnome="gnome gnome-terminal gdm gnome-tweaks nautilus nautilus-sendto gnome-usage "
gnome+="chrome-gnome-shell xdg-user-dirs-gtk fwupd seahorse"

# Extra Packages
extra="google-chrome libreoffice-fresh libreoffice-fresh-pt-br pamac-aur-tray-appindicator-git "
extra+="telegram-desktop virtualbox-host-dkms virtualbox"

function install_pkg() {
  package_name=$1
  pkg=$2
  echo "Installing: ${package_name}"
  yay -S ${pkg} --needed --noconfirm --quiet
}

install_pkg "Gnome" $gnome
install_pkg "Extra" $extra
