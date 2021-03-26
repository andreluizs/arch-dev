#!/usr/bin/env sh

set -o errexit
set -o pipefail

base_git_hub_url="https://raw.githubusercontent.com/andreluizs/arch-dev/master"
dotfiles_url="${base_git_hub_url}/dotfiles"
pos_install_url="${base_git_hub_url}/pos-install.sh"
dev_install_url="${base_git_hub_url}/dev-install.sh"

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
