#!/usr/bin/env sh

set -o errexit
set -o pipefail

base_git_hub_url="https://raw.githubusercontent.com/andreluizs/arch-dev/master"
dotfiles_url="${base_git_hub_url}/dotfiles"
pos_install_url="${base_git_hub_url}/pos-install.sh"
dev_install_url="${base_git_hub_url}/dev-install.sh"

# Pacstrap
base_package="intel-ucode networkmanager networkmanager-openconnect bash-completion xorg xorg-xinit xf86-video-intel ntfs-3g "
base_package+="gnome-themes-standard gtk-engine-murrine sassc gvfs xdg-user-dirs git nano "
base_package+="noto-fonts-emoji ttf-dejavu ttf-liberation noto-fonts ttf-droid "
base_package+="pulseaudio pulseaudio-alsa p7zip zip unzip unrar wget openssh xclip curl"

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
)

gnome=(
  "gnome"
  "gdm"
  "gnome-tweaks"
  "nautilus-sendto"
  "gnome-nettool"
  "gnome-usage"
  "chrome-gnome-shell"
  "xdg-user-dirs-gtk"
  "fwupd"
  "seahorse"
)

developer_tools=(
  "ttf-fira-code"
  "ttf-jetbrains-mono"
  "visual-studio-code-bin"
  "insomnia"
  "slack-desktop"
  "teams-insiders"
  "openfortigui"
)

extra=(
  "google-chrome"
  "libreoffice-fresh"
  "libreoffice-fresh-pt-br"
  "pamac-aur-tray-appindicator-git"
  "zsh"
  "zsh-completions"
  "telegram-desktop"
  "virtualbox-host-dkms"
  "virtualbox"
)

# Programs Versions
maven_version="apache-maven-3.6.3-bin.tar.gz"
intellij_version="ideaIC-2020.3.3.tar.gz"

# Help Functions
function _chroot() {
  arch-chroot /mnt /bin/bash -c "$1"
}

function _chuser() {
  _chroot "su ${my_user} -c \"$1\""
}

function _spinner() {
  local pid=$2
  local i=1
  local param=$1
  local sp='/-\|'
  echo -ne "$param "
  while [ -d /proc/"${pid}" ]; do
    printf "[%c]   " "${sp:i++%${#sp}:1}"
    sleep 0.75
    printf "\\b\\b\\b\\b\\b\\b"
  done
}

function install_pkg() {
  local packages=("$@")
  for i in "${packages[@]}"; do
    echo "+ Instalando: ${i}"
    yay -S ${i} --needed --noconfirm --quiet &>/dev/null
  done
}
