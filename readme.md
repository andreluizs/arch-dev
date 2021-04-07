<p align="center">
    <img src="https://github.com/andreluizs/arch-cvc/blob/master/docs/logo.png?raw=true" width="20%">  
</p>

## Arch DEV - Scripts

> install.sh  
> pos-install.sh  
> dev-install.sh

## Install Base System
> ```shell 
> # Warning this action will be erase your disk
> bash <(curl -s -L bit.do/arch-dev) 
> ```
## Pos-Install
> After install base system, reboot and inside your `$HOME` execute:
> ```shell 
> # Desktop Environment
> bash pos-install.sh
>
> # Tools for Developer
> bash dev-install.sh
>```

## Test Script
- Create VM
> ```shell 
> VBoxManage createvm --name "Arch" --ostype ArchLinux_64 --register
> VBoxManage modifyvm "Arch" --cpus 2 --memory 4096 --vram 128 --firmware efi --graphicscontroller vmsvga --usbohci on --mouse usbtablet --accelerate3d on
> VBoxManage createhd --filename "$HOME/VirtualBox VMs/Arch/Arch.vdi" --size 30000
> VBoxManage storagectl "Arch" --name "SATA Controller" --add sata --controller IntelAhci
> VBoxManage storageattach "Arch" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VMs/Arch.vdi"
> VBoxManage storagectl "Arch" --name "IDE Controller" --add ide --controller PIIX4
> VBoxManage storageattach "Arch" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium emptydrive
> VBoxManage modifyvm "Arch" --boot1 dvd --boot2 disk --boot3 none --boot4 none
>```
> Enable SSH access
>```shell
> VBoxManage modifyvm "Arch" --natpf1 "SSH,tcp,,2022,,22"
>```
> Create a Snapshot
>```shell
> VBoxManage snapshot "Arch" take "arch-ssh"
> ```
> Restore a Snapshot
>```shell
> VBoxManage snapshot "Arch" restore "arch-ssh"
> ```
> Remove a Snapshot
>```shell
> VBoxManage snapshot "Arch" remove "arch-ssh"
> ```
> Remove a Virtual Machine
>```shell
> VBoxManage unregistervm --delete "Arch"
> ```
> Start Virtual Machine (headless)
>```shell
> VBoxManage startvm "Arch" --type headless
> ```
### Connecting using SSH  
- Start vm with archlinux.iso.
- Change root password (`passwd`)
- Start ssh service (`systemctl start sshd.service`)
- Take snapshot
- Start vm in headless mode
- Connect: `ssh -p 2022 root@127.0.0.1`
