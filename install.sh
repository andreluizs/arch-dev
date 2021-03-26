#!/usr/bin/env sh

source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-dev/master/config.sh)

ssd="/dev/sda"
my_user="andre"
my_user_name="André Santos"
machine_name="arch"

# Pacstrap
base_package="intel-ucode networkmanager networkmanager-openconnect bash-completion xorg xf86-video-intel ntfs-3g "
base_package+="gnome-themes-standard gtk-engine-murrine gvfs xdg-user-dirs git nano "
base_package+="noto-fonts-emoji ttf-dejavu ttf-liberation noto-fonts ttf-droid "
base_package+="pulseaudio pulseaudio-alsa p7zip zip unzip unrar wget openssh xclip curl"

function init() {
  clear
  echo "+-------------- ARCH DEV - INSTALL -------------+"
  umount -R /mnt &>/dev/null || /bin/true
  echo "+ Setting mirrors."
  pacman -Sy reflector --needed --noconfirm &>/dev/nul
  reflector --country Brazil --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/nul
}

function format_hd() {
  echo "+ Resetting partition table"
  parted -s "$ssd" mklabel gpt 1>/dev/nul

  echo "+ Creating partition /boot"
  parted "$ssd" mkpart ESP fat32 1MiB 513MiB &>/dev/nul
  parted "$ssd" set 1 boot on &>/dev/nul

  echo "+ Creating partition /root"
  parted "$ssd" mkpart primary ext4 513MiB 100% &>/dev/nul

  echo "+ Formatting partitions."
  mkfs.vfat -F32 "${ssd}1" -n BOOT &>/dev/nul
  mkfs.ext4 -F -L ROOT "${ssd}2" &>/dev/nul
}

function mount_partition() {
  echo "+ Mounting partitions"
  mount "${ssd}2" /mnt
  mkdir -p /mnt/boot
  mkdir -p /mnt/home
  mount "${ssd}1" /mnt/boot
  echo "+-------------------- TABLE --------------------+"
  lsblk ${ssd} -o name,size,mountpoint
  echo "+-----------------------------------------------+"
}

function install_base_system() {
  (pacstrap /mnt base base-devel linux-lts linux-firmware ${base_package} &>/dev/null) &
  _spinner "+ Installing base system:" $!
  echo -ne "[100%]\\n"

  echo "+ Generating FSTAB"
  genfstab -U /mnt >>/mnt/etc/fstab

  echo "+ Updating pacman's mirrorlist"
  _chroot "pacman -S reflector --needed --noconfirm" &>/dev/null
  _chroot "reflector --country Brazil --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist" &>/dev/null
  _chroot "sed -i '/multilib]/,+1  s/^#//' /etc/pacman.conf"
  _chroot "pacman -Sy" &>/dev/null

}

function create_swapfile() {
  echo "+ Creating swapfile with 8GB"
  _chroot "dd if=/dev/zero of=/swapfile bs=1M count=8196 status=progress" &>/dev/null
  _chroot "chmod 600 /swapfile" 1>/dev/null
  _chroot "mkswap /swapfile" 1>/dev/null
  _chroot "swapon /swapfile" 1>/dev/null
  _chroot "echo -e /swapfile none swap defaults 0 0 >> /etc/fstab"
}

function install_systemd_boot() {
  echo "+ Installing bootloader."
  _chroot "bootctl --path=/boot install" &>/dev/null
  _chroot "wget ${dotfiles_url}/bootloader/loader.conf -qO /boot/loader/loader.conf"
  _chroot "wget ${dotfiles_url}/bootloader/arch.conf -qO /boot/loader/entries/arch.conf"
  _chroot "sed -i \"s%{device}%${ssd}2%\" /boot/loader/entries/arch.conf"
  _chroot "wget ${dotfiles_url}/bootloader/arch-rescue.conf -qO /boot/loader/entries/arch-rescue.conf"
  _chroot "sed -i \"s%{device}%${ssd}2%\" /boot/loader/entries/arch-rescue.conf"
  _chroot "mkdir -p /etc/pacman.d/hooks" &>/dev/null
  _chroot "wget ${dotfiles_url}/bootloader/systemd-boot.hook -qO /etc/pacman.d/hooks/systemd-boot.hook"
  _chroot "mkinitcpio -p linux-lts" &>/dev/null
}

function setup_system() {
  echo "+ Setting language"
  _chroot "echo -e \"KEYMAP=br-abnt2\\nFONT=\\nFONT_MAP=\" > /etc/vconsole.conf"
  _chroot "sed -i '/en_US/,+1 s/^#//' /etc/locale.gen"
  _chroot "locale-gen" 1>/dev/null
  _chroot "echo LANG=en_US.UTF-8 > /etc/locale.conf"
  _chroot "export LANG=en_US.UTF-8"

  echo "+ Creating user"
  _chroot "useradd -m -g users -G wheel -c \"${my_user_name}\" -s /bin/bash $my_user"
  _chroot "echo ${my_user}:${my_user} | chpasswd"
  _chroot "echo root:${my_user} | chpasswd"
  _chroot "sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers"
  _chroot "echo \"$machine_name\" > /etc/hostname"

  echo "+ Installing yay package manager"
  _chuser "mkdir -p /home/${my_user}/tmp"
  _chuser "cd /home/${my_user}/tmp && git clone https://aur.archlinux.org/yay.git" &>/dev/null
  _chuser "cd /home/${my_user}/tmp/yay && makepkg -si --noconfirm" &>/dev/null
  _chuser "rm -rf /home/${my_user}/tmp"

  echo "+ Putting the pos-install.sh script in /home"
  _chuser "wget ${pos_install_url} -qO /home/${my_user}/pos-install.sh"

  echo "+ Putting the dev-install.sh script in /home"
  _chuser "wget ${dev_install_url} -qO /home/${my_user}/dev-install.sh"
}

init
format_hd
mount_partition
install_base_system
create_swapfile
install_systemd_boot
setup_system
echo "+--------- ARCH SUCCESSFULLY INSTALLED ---------+"
umount -R /mnt &>/dev/null || /bin/true
echo
