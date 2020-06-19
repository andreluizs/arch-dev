#!/usr/bin/env sh

set -o errexit
set -o pipefail

# XFCE
XFCE=(
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
  "xfce-polkit-git")

DEV=(
  "ttf-fira-code"
  "visual-studio-code-bin"
  "insomnia"
  "zsh"
  "zsh-completions"
  "slack-desktop"
  "teams-insiders"
  "telegram-desktop"
  "nvm"
  "jabba"
)

EXTRA=(
  "google-chrome"
  "libreoffice-fresh"
  "libreoffice-fresh-pt-br"
  "pamac-aur-tray-appindicator-git"
)


function installPkg() {
  local pacotes=("$@")
  for i in "${pacotes[@]}"; do
    echo -ne "Install: ${i}"
    yay -S ${i} --needed --noconfirm --quiet --noinfo
  done
}

function installLightDM() {
  echo -ne "Install LightDM"
  yay -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker --needed --noconfirm --quiet --noinfo
  sudo sed -i '/^#greeter-session/c \greeter-session=lightdm-gtk-greeter' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm.service
}

function installDocker() {
  echo -ne "Install Docker"
  yay -S docker docker-compose --needed --noconfirm --quiet --noinfo
  usermod -aG docker $USER
  sudo touch /etc/docker/daemon.json
  cat <<EOF >/etc/docker/daemon.json
{
  "registry-mirrors": [],
  "insecure-registries": [],
  "debug": true,
  "storage-opt": [
    "size=10G"
  ],
  "experimental": true,
  "insecure-registries" : [ "iac-harbor.compute.br-sao-1.cvccorp.cloud" ],
  "bip": "192.168.10.5/23",
  "fixed-cidr":"192.168.10.5/23"
}
EOF
}

function installVpn() {
  yay -S pritunl-client openvpngui --needed --noconfirm --quiet --noinfo
}

function installIntellij() {
  intellijVersion = "ideaIU-2020.1.2"
  mkdir -p ~/intellij && cd ~/intellij
  wget "https://download.jetbrains.com/idea/${intellijVersion}.tar.gz"
  tar -xvzf "${intellijVersion}.tar.gz"
}

installPkg $XFCE
installPkg $EXTRA
installPkg $DEV
