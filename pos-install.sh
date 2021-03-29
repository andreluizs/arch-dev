#!/usr/bin/env sh

set -o errexit
set -o pipefail

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
function install_gnome() {
  local gnome="gnome-shell gnome-terminal gdm gnome-tweaks nautilus nautilus-sendto chrome-gnome-shell fwupd"
  echo "# Installing Gnome"
  yay -S ${gnome} --needed --noconfirm --quiet &>/dev/null
}

# Extra Packages
function install_extra() {
  local extra="google-chrome libreoffice-fresh libreoffice-fresh-pt-br pamac-aur "
  extra+="telegram-desktop virtualbox-host-dkms virtualbox"
  echo "# Installing Extra"
  yay -S ${extra} --needed --noconfirm --quiet &>/dev/null
}

clear
yay -Syyu --noconfirm &> /dev/null
install_gnome
install_extra
