#!/usr/bin/env sh

source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-dev/master/_common.sh)

ssd="/dev/nvme0n1"
user="andre"
user_name="André Santos"
hostname="arch"

# Pacstrap
base_package="intel-ucode networkmanager networkmanager-openconnect bash-completion xorg ntfs-3g "
base_package+="gnome-themes-standard gtk-engine-murrine gvfs xdg-user-dirs git nano "
base_package+="noto-fonts-emoji noto-fonts ttf-cascadia-code "
base_package+="pipewire pipewire-pulse pipewire-alsa sof-firmware p7zip zip unzip unrar wget openssh xclip curl "
base_package+="mesa lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader "


function init() {
  clear
  echo "+-------------- ARCH DEV - INSTALL -------------+"
  umount -R /mnt &>/dev/null || /bin/true
  echo "+ Setting mirrors"
  sed -i '/multilib]/,+1  s/^#//' /etc/pacman.conf
  pacman -Sy reflector --needed --noconfirm &>/dev/nul
  reflector --country br,us --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
}

function format_hd() {
  echo "+ Resetting partition table"
  parted -s "$ssd" mklabel gpt 1>/dev/nul

  echo "+ Creating partition /boot"
  parted "$ssd" mkpart ESP fat32 1MiB 513MiB &>/dev/nul
  parted "$ssd" set 1 boot on &>/dev/nul

  echo "+ Creating partition /root"
  parted "$ssd" mkpart primary ext4 513MiB 100% &>/dev/nul

  echo "+ Formatting partitions"
  mkfs.vfat -F32 "${ssd}p1" -n BOOT &>/dev/nul
  mkfs.ext4 -F -L ROOT "${ssd}p2" &>/dev/nul
}

function mount_partition() {
  echo "+ Mounting partitions"
  mount "${ssd}p2" /mnt
  mkdir -p /mnt/boot
  mkdir -p /mnt/home
  mount "${ssd}p1" /mnt/boot
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
  _chroot "reflector --country br,us --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist" &>/dev/null
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
  echo "+ Installing bootloader"
  _chroot "bootctl --path=/boot install" &>/dev/null
  _chroot "wget ${configs_url}/bootloader/loader.conf -qO /boot/loader/loader.conf"
  _chroot "wget ${configs_url}/bootloader/arch.conf -qO /boot/loader/entries/arch.conf"
  _chroot "sed -i \"s%{device}%${ssd}p2%\" /boot/loader/entries/arch.conf"
  _chroot "wget ${configs_url}/bootloader/arch-rescue.conf -qO /boot/loader/entries/arch-rescue.conf"
  _chroot "sed -i \"s%{device}%${ssd}p2%\" /boot/loader/entries/arch-rescue.conf"
  _chroot "mkdir -p /etc/pacman.d/hooks" &>/dev/null
  _chroot "wget ${configs_url}/bootloader/systemd-boot.hook -qO /etc/pacman.d/hooks/systemd-boot.hook"
  _chroot "mkinitcpio -p linux-lts" &>/dev/null
}

function setup_system() {
  echo "+ Setting language"
  _chroot "echo -e \"KEYMAP=br-abnt2\\nFONT=\\nFONT_MAP=\" > /etc/vconsole.conf"
  _chroot "sed -i '/en_US/,+1 s/^#//' /etc/locale.gen"
  _chroot "sed -i '/pt_BR/,+1 s/^#//' /etc/locale.gen"
  _chroot "locale-gen" 1>/dev/null
  _chroot "echo LANG=pt_BR.UTF-8 > /etc/locale.conf"
  _chroot "export LANG=pt_BR.UTF-8"

  echo "+ Creating user"
  _chroot "useradd -m -g users -G wheel -c \"${user_name}\" -s /bin/bash $user"
  _chroot "echo ${user}:${user} | chpasswd"
  _chroot "echo root:${user} | chpasswd"
  _chroot "sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers"
  _chroot "echo \"$hostname\" > /etc/hostname"

  echo "+ Installing yay package manager"
  _chuser "mkdir -p /home/${user}/tmp"
  _chuser "cd /home/${user}/tmp && git clone https://aur.archlinux.org/yay.git" &>/dev/null
  _chuser "cd /home/${user}/tmp/yay && makepkg -si --noconfirm" &>/dev/null
  _chuser "rm -rf /home/${user}/tmp"

  echo "+ Putting the pos-install.sh script in /home"
  _chuser "wget ${pos_install_url} -qO /home/${user}/pos-install.sh"

  echo "+ Putting the dev-install.sh script in /home"
  _chuser "wget ${dev_install_url} -qO /home/${user}/dev-install.sh"

  echo "+ Enable services "
  _chroot "systemctl enable NetworkManager.service"
  _chroot "systemctl enable fstrim.timer"
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
