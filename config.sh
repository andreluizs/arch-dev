#!/usr/bin/env sh

set -o errexit
set -o pipefail

DOTFILES="https://raw.githubusercontent.com/andreluizs/arch-cvc/master/dotfiles"

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
  "pritunl-client"
  "openvpngui"
)

EXTRA=(
  "google-chrome"
  "libreoffice-fresh"
  "libreoffice-fresh-pt-br"
  "pamac-aur-tray-appindicator-git"
)

# Programs Versions
APACHE_MAVEN="apache-maven-3.6.3-bin.tar.gz"
INTELLIJ="ideaIU-2020.1.2.tar.gz"

# Help Functions
function installPkg() {
  local packages=("$@")
  for i in "${packages[@]}"; do
    echo "Install: ${i}"
    yay -S ${i} --needed --noconfirm --quiet
  done
}
