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
    echo "Install: ${i}"
    yay -S ${i} --needed --noconfirm --quiet --noinfo
  done
}

function installLightDM() {
  echo "Install LightDM"
  yay -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker --needed --noconfirm --quiet --noinfo
  sudo sed -i '/^#greeter-session/c \greeter-session=lightdm-gtk-greeter' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm.service
}

function installDocker() {
  echo "Install Docker"
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
  name="ideaIU-2020.1.2"
  mkdir -p ~/jetbrains && cd ~/jetbrains
  echo "# Baixando"
  wget -c "https://download.jetbrains.com/idea/${name}.tar.gz" -q --show-progress
  echo "# Descompactando"
  tar -xzf "${name}.tar.gz"
  sudo mv idea-* /opt/intellij-ultimate
  sudo chown -R $USER /opt/intellij-ultimate
  echo "# Instalação Concluída"
  bash /opt/intellij-ultimate/bin/idea.sh &
  echo "# Limpando"
  rm -rf ~/jetbrains
}

function installMaven() {
  file="apache-maven-3.6.3-bin.tar.gz"
  name="maven-3.6.3"
  mkdir -p ~/maven && cd ~/maven
  echo "# Baixando"
  wget -c "http://ftp.unicamp.br/pub/apache/maven/maven-3/3.6.3/binaries/${file}" -q --show-progress
  echo "# Descompactando"
  tar -xzf $file
  rm -rf *.tar.gz
  sudo mv apache-* /opt/$name
  sudo chown -R $USER /opt/$name
  echo "# Instalação Concluída"
  cat <<EOF >>~/.zshrc

# MAVEN
export M2_HOME=/opt/$name
export PATH=\$M2_HOME/bin:\$PATH
EOF
  echo "# Limpando"
  rm -rf ~/maven
}

#installPkg $XFCE
#installPkg $EXTRA
#installPkg $DEV
#installIntellij
#installMaven
