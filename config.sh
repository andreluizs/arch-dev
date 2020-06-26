#!/usr/bin/env sh

set -o errexit
set -o pipefail

base_git_hub_url="https://raw.githubusercontent.com/andreluizs/arch-cvc/master"
dotfiles_url="${base_git_hub_url}/dotfiles"
pos_install_url="${base_git_hub_url}/pos-install.sh"
dev_install_url="${base_git_hub_url}/dev-install.sh"

# Pacstrap
base_package="intel-ucode networkmanager bash-completion xorg xorg-xinit xf86-video-intel ntfs-3g "
base_package+="gnome-themes-standard gtk-engine-murrine gvfs xdg-user-dirs git nano "
base_package+="noto-fonts-emoji ttf-dejavu ttf-liberation noto-fonts "
base_package+="pulseaudio pulseaudio-alsa p7zip zip unzip unrar wget openssh xclip curl"

# XFCE
desktop_environment=(
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

developer_tools=(
  "ttf-fira-code"
  "visual-studio-code-bin"
  "insomnia"
  "slack-desktop"
  "teams-insiders"
  "nvm"
  "jabba"
  "pritunl-client"
  "openvpngui"
)

extra=(
  "google-chrome"
  "libreoffice-fresh"
  "libreoffice-fresh-pt-br"
  "pamac-aur-tray-appindicator-git"
  "zsh"
  "zsh-completions"
  "telegram-desktop"
)

# Bootloader Entries
loader="timeout 3\ndefault arch"
arch_entrie="title Arch Linux\\nlinux /vmlinuz-linux\\n\\ninitrd  intel-ucode.img\\ninitrd initramfs-linux.img\\noptions root=${ssd}2 rw"
arch_rescue="title Arch Linux (Rescue)\\nlinux vmlinuz-linux\\n\\ninitrd  intel-ucode.img\\ninitrd initramfs-linux.img\\noptions root=${ssd}2 rw systemd.unit=rescue.target"
boot_hook="[Trigger]\\nType = Package\\nOperation = Upgrade\\nTarget = systemd\\n\\n[Action]\\nDescription = Updating systemd-boot\\nWhen = PostTransaction\\nExec = /usr/bin/bootctl --path=/boot update"

# Programs Versions
maven_version="apache-maven-3.6.3-bin.tar.gz"
intellij_version="ideaIU-2020.1.2.tar.gz"

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