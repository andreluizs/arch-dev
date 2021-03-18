#!/usr/bin/env sh

set -o errexit
set -o pipefail

# source config.sh
source <(curl -s https://raw.githubusercontent.com/andreluizs/cvc-arch/master/config.sh)

function install_desktop_environment() {
  for i in "${gnome[@]}"; do
    echo "+ Instalando: ${i}"
    yay -S ${i} --needed --noconfirm --quiet &>/dev/null
  done
}

function install_light_dm() {
  echo "Install LightDM"
  yay -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker --needed --noconfirm --quiet
  sudo sed -i '/^#greeter-session/c \greeter-session=lightdm-gtk-greeter' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm.service
}

function install_extras() {
  for i in "${extra[@]}"; do
    echo "+ Instalando: ${i}"
    yay -S ${i} --needed --noconfirm --quiet &>/dev/null
  done
}

clear
install_desktop_environment
#install_light_dm
install_extras
