#!/usr/bin/env sh

set -o errexit
set -o pipefail

SSD="/dev/sda"
MY_USER="andre"
MY_USER_NAME="André Santos"
HOST="arch"

BASE_PKG="intel-ucode networkmanager bash-completion xorg xorg-xinit xf86-video-intel ntfs-3g "
BASE_PKG+="gnome-themes-standard gtk-engine-murrine gvfs xdg-user-dirs git nano "
BASE_PKG+="noto-fonts-emoji ttf-dejavu ttf-liberation noto-fonts "
BASE_PKG+="pulseaudio pulseaudio-alsa p7zip zip unzip unrar wget openssh xclip curl"

POS_INSTALL="https://raw.githubusercontent.com/andreluizs/arch-cvc/master/pos-install.sh"

function _chroot() {
  arch-chroot /mnt /bin/bash -c "$1"
}

function _chuser() {
  _chroot "su ${MY_USER} -c \"$1\""
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

function init() {
  clear
  echo "+---------------- ARCH - INSTALL ---------------+"
  umount -R /mnt &>/dev/null || /bin/true
  echo "+ Configurando mirrors."
  pacman -Sy reflector --needed --noconfirm &> /dev/nul
  reflector --country Brazil --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist &> /dev/nul
}

function formatHD() {
  echo "+ Resetanto a tabela de partições"
  parted -s "$SSD" mklabel gpt 1> /dev/nul

  echo "+ Criando a partição /boot"
  parted "$SSD" mkpart ESP fat32 1MiB 513MiB &> /dev/nul
  parted "$SSD" set 1 boot on &> /dev/nul

  echo "+ Criando a partição /root"
  parted "$SSD" mkpart primary ext4 513MiB 100% &> /dev/nul

  echo "+ Formatando as partições."
  mkfs.vfat -F32 "${SSD}1" -n BOOT &> /dev/nul
  mkfs.ext4 -F -L ROOT "${SSD}2" &> /dev/nul
}

function mountPartition() {
  echo "+ Montando as partições."
  mount "${SSD}2" /mnt
  mkdir -p /mnt/boot
  mkdir -p /mnt/home
  mount "${SSD}1" /mnt/boot
  echo "+------------------- TABELA --------------------+"
  lsblk ${SSD} -o name,size,mountpoint
  echo "+-----------------------------------------------+"
}

function installOperationSystem() {

  (pacstrap /mnt base base-devel linux linux-firmware ${BASE_PKG} &>/dev/null) &
  _spinner "+ Instalando o sistema:" $!
  echo -ne "[100%]\\n"

  echo "+ Gerando fstab."
  genfstab -U /mnt >>/mnt/etc/fstab

  echo "+ Atualizando o mirrorlist."
  _chroot "pacman -S reflector --needed --noconfirm" &>/dev/null
  _chroot "reflector --country Brazil --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist" &>/dev/null
  _chroot "sed -i '/multilib]/,+1  s/^#//' /etc/pacman.conf"
  _chroot "pacman -Sy" &>/dev/null

}

function createSwapFile() {
  echo "+ Criando o swapfile com 4GB."
  _chroot "fallocate -l \"4096M\" /swapfile" 1>/dev/null
  _chroot "chmod 600 /swapfile" 1>/dev/null
  _chroot "mkswap /swapfile" 1>/dev/null
  _chroot "swapon /swapfile" 1>/dev/null
  _chroot "echo -e /swapfile none swap defaults 0 0 >> /etc/fstab"
}

function installSystemDBoot() {
  echo "+ Instalando o bootloader."
  local loader="timeout 3\ndefault arch"
  local arch_entrie="title Arch Linux\\nlinux /vmlinuz-linux\\n\\ninitrd  intel-ucode.img\\ninitrd initramfs-linux.img\\noptions root=${SSD}2 rw"
  local arch_rescue="title Arch Linux (Rescue)\\nlinux vmlinuz-linux\\n\\ninitrd  intel-ucode.img\\ninitrd initramfs-linux.img\\noptions root=${SSD}2 rw systemd.unit=rescue.target"
  local boot_hook="[Trigger]\\nType = Package\\nOperation = Upgrade\\nTarget = systemd\\n\\n[Action]\\nDescription = Updating systemd-boot\\nWhen = PostTransaction\\nExec = /usr/bin/bootctl --path=/boot update"

  _chroot "bootctl --path=/boot install" &>/dev/null
  _chroot "echo -e \"${loader}\" > /boot/loader/loader.conf" &>/dev/null
  _chroot "echo -e \"${arch_entrie}\" > /boot/loader/entries/arch.conf" &>/dev/null
  _chroot "echo -e \"${arch_rescue}\" > /boot/loader/entries/arch-rescue.conf" &>/dev/null
  _chroot "mkdir -p /etc/pacman.d/hooks" &>/dev/null
  _chroot "echo -e \"${boot_hook}\" > /etc/pacman.d/hooks/systemd-boot.hook" &>/dev/null
  _chroot "mkinitcpio -p linux" &>/dev/null
}

function setupSystem() {
  echo "+ Configurando o idioma."
  _chroot "echo -e \"KEYMAP=br-abnt2\\nFONT=\\nFONT_MAP=\" > /etc/vconsole.conf"
  _chroot "sed -i '/pt_BR/,+1 s/^#//' /etc/locale.gen"
  _chroot "locale-gen" 1>/dev/null
  _chroot "echo LANG=pt_BR.UTF-8 > /etc/locale.conf"
  _chroot "export LANG=pt_BR.UTF-8"

  echo "+ Criando o usuário."
  _chroot "useradd -m -g users -G wheel -c \"${MY_USER_NAME}\" -s /bin/bash $MY_USER"
  _chroot "echo ${MY_USER}:${MY_USER} | chpasswd"
  _chroot "echo root:${MY_USER} | chpasswd"
  _chroot "sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers"
  _chroot "echo \"$HOST\" > /etc/hostname"

  echo "+ Instalando o yay."
  _chuser "mkdir -p /home/${MY_USER}/tmp"
  _chuser "cd /home/${MY_USER}/tmp && git clone https://aur.archlinux.org/yay.git" &>/dev/null
  _chuser "cd /home/${MY_USER}/tmp/yay && makepkg -si --noconfirm" &>/dev/null
  _chuser "rm -rf /home/${MY_USER}/tmp"

  echo "+ Baixando o pos-install.sh na pasta home"
  _chuser "wget ${POS_INSTALL} -qO /home/${MY_USER}/pos-install.sh"
  
}

init
formatHD
mountPartition
installOperationSystem
createSwapFile
installSystemDBoot
setupSystem
echo "+-------- SISTEMA INSTALADO COM SUCESSO --------+"
umount -R /mnt &>/dev/null || /bin/true
echo
