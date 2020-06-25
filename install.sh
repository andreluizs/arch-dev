#!/usr/bin/env sh

set -o errexit
set -o pipefail

# source config.sh
source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-cvc/master/config.sh)

ssd="/dev/sda"
my_user="andre"
my_user_name="André Santos"
machine_name="arch"

function init() {
  clear
  echo "+---------------- ARCH - INSTALL ---------------+"
  umount -R /mnt &>/dev/null || /bin/true
  echo "+ Configurando mirrors."
  pacman -Sy reflector --needed --noconfirm &>/dev/nul
  reflector --country Brazil --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/nul
}

function format_hd() {
  echo "+ Resetanto a tabela de partições"
  parted -s "$ssd" mklabel gpt 1>/dev/nul

  echo "+ Criando a partição /boot"
  parted "$ssd" mkpart ESP fat32 1MiB 513MiB &>/dev/nul
  parted "$ssd" set 1 boot on &>/dev/nul

  echo "+ Criando a partição /root"
  parted "$ssd" mkpart primary ext4 513MiB 100% &>/dev/nul

  echo "+ Formatando as partições."
  mkfs.vfat -F32 "${ssd}1" -n BOOT &>/dev/nul
  mkfs.ext4 -F -L ROOT "${ssd}2" &>/dev/nul
}

function mount_partition() {
  echo "+ Montando as partições."
  mount "${ssd}2" /mnt
  mkdir -p /mnt/boot
  mkdir -p /mnt/home
  mount "${ssd}1" /mnt/boot
  echo "+------------------- TABELA --------------------+"
  lsblk ${ssd} -o name,size,mountpoint
  echo "+-----------------------------------------------+"
}

function install_base_system() {
  (pacstrap /mnt base base-devel linux linux-firmware ${base_package} &>/dev/null) &
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

function create_swapfile() {
  echo "+ Criando o swapfile com 4GB."
  _chroot "fallocate -l \"4096M\" /swapfile" 1>/dev/null
  _chroot "chmod 600 /swapfile" 1>/dev/null
  _chroot "mkswap /swapfile" 1>/dev/null
  _chroot "swapon /swapfile" 1>/dev/null
  _chroot "echo -e /swapfile none swap defaults 0 0 >> /etc/fstab"
}

function install_systemd_boot() {
  echo "+ Instalando o bootloader."
  _chroot "bootctl --path=/boot install" &>/dev/null
  _chroot "echo -e \"${loader}\" > /boot/loader/loader.conf" &>/dev/null
  _chroot "echo -e \"${arch_entrie}\" > /boot/loader/entries/arch.conf" &>/dev/null
  _chroot "echo -e \"${arch_rescue}\" > /boot/loader/entries/arch-rescue.conf" &>/dev/null
  _chroot "mkdir -p /etc/pacman.d/hooks" &>/dev/null
  _chroot "echo -e \"${boot_hook}\" > /etc/pacman.d/hooks/systemd-boot.hook" &>/dev/null
  _chroot "mkinitcpio -p linux" &>/dev/null
}

function setup_system() {
  echo "+ Configurando o idioma."
  _chroot "echo -e \"KEYMAP=br-abnt2\\nFONT=\\nFONT_MAP=\" > /etc/vconsole.conf"
  _chroot "sed -i '/pt_BR/,+1 s/^#//' /etc/locale.gen"
  _chroot "locale-gen" 1>/dev/null
  _chroot "echo LANG=pt_BR.UTF-8 > /etc/locale.conf"
  _chroot "export LANG=pt_BR.UTF-8"

  echo "+ Criando o usuário."
  _chroot "useradd -m -g users -G wheel -c \"${my_user_name}\" -s /bin/bash $my_user"
  _chroot "echo ${my_user}:${my_user} | chpasswd"
  _chroot "echo root:${my_user} | chpasswd"
  _chroot "sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers"
  _chroot "echo \"$machine_name\" > /etc/hostname"

  echo "+ Instalando o yay."
  _chuser "mkdir -p /home/${my_user}/tmp"
  _chuser "cd /home/${my_user}/tmp && git clone https://aur.archlinux.org/yay.git" &>/dev/null
  _chuser "cd /home/${my_user}/tmp/yay && makepkg -si --noconfirm" &>/dev/null
  _chuser "rm -rf /home/${my_user}/tmp"

  echo "+ Baixando o pos-install.sh na pasta home"
  _chuser "wget ${pos_install_url} -qO /home/${my_user}/pos-install.sh"

  echo "+ Baixando o dev-install.sh na pasta home"
  _chuser "wget ${dev_install_url} -qO /home/${my_user}/dev-install.sh"
}

init
format_hd
mount_partition
install_base_system
create_swapfile
install_systemd_boot
setup_system
echo "+-------- SISTEMA INSTALADO COM SUCESSO --------+"
umount -R /mnt &>/dev/null || /bin/true
echo
