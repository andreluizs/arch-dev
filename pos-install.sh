#!/usr/bin/env sh

set -o errexit
set -o pipefail

# source config.sh
source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-cvc/master/config.sh)

function install_light_dm() {
  echo "Install LightDM"
  yay -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker --needed --noconfirm --quiet
  sudo sed -i '/^#greeter-session/c \greeter-session=lightdm-gtk-greeter' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm.service
}

clear
install_pkg "${desktop_environment[@]}"
install_light_dm
install_pkg "${extra[@]}"
