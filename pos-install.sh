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
  sudo wget "${DOTFILES}/docker/daemon.json" -qO /etc/docker/daemon.json
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
  echo "# Instalando"
  sudo mv idea-* /opt/intellij-ultimate
  sudo chown -R $USER /opt/intellij-ultimate
  bash /opt/intellij-ultimate/bin/idea.sh &
  echo "# Limpando arquivos desnecessários"
  rm -rf ~/jetbrains
  echo "# Instalação concluída"
}

function installMaven() {
  file="apache-maven-3.6.3-bin.tar.gz"
  mkdir -p ~/maven && cd ~/maven
  echo "# Baixando"
  wget -c "http://ftp.unicamp.br/pub/apache/maven/maven-3/3.6.3/binaries/${file}" -q --show-progress
  echo "# Descompactando"
  tar -xzf $file
  rm -rf *.tar.gz
  echo "# Instalando"
  sudo rm -rf /opt/maven
  sudo mv apache-* /opt/maven
  sudo chown -R $USER /opt/maven
  echo "# Adicionando à variável no ambiente"
  wget "${DOTFILES}/maven/path.txt" -O >> $HOME/.zshrc
  mkdir -p $HOME/.m2 && wget "${DOTFILES}/maven/settings.xml" -qO $HOME/.m2/settings.xml
  echo "# Limpando arquivos desnecessários"
  rm -rf ~/maven
  echo "# Instalação concluída"
}

#installPkg $XFCE
#installPkg $EXTRA
#installPkg $DEV
#installIntellij
#installMaven
