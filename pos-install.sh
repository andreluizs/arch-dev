#!/usr/bin/env sh

set -o errexit
set -o pipefail

# source config.sh
source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-cvc/master/config.sh)

function installLightDM() {
  echo "Install LightDM"
  yay -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker --needed --noconfirm --quiet
  sudo sed -i '/^#greeter-session/c \greeter-session=lightdm-gtk-greeter' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm.service
}

function installDocker() {
  echo "# Instalando o Docker e Docker Compose"
  yay -S docker docker-compose --needed --noconfirm --quiet 
  echo "# Adicionado o ${USER} ao grupo do docker"
  usermod -aG docker $USER
  echo "# Modificando o range de IP's para não conflitar com os ambientes de QA da CVC"
  sudo wget "${DOTFILES}/docker/daemon.json" -qO /etc/docker/daemon.json
  echo "# Instalação concluída."
}

function installIntellij() {
  mkdir -p ~/.tmp_intellij && cd ~/.tmp_intellij
  echo "# Baixando"
  wget -c "https://download.jetbrains.com/idea/${INTELLIJ}" -q --show-progress
  echo "# Descompactando"
  tar -xzf $INTELLIJ
  echo "# Instalando"
  sudo mv idea-* /opt/intellij-ultimate
  sudo chown -R $USER /opt/intellij-ultimate
  bash /opt/intellij-ultimate/bin/idea.sh &
  echo "# Limpando arquivos desnecessários"
  rm -rf ~/tmp_intellij
  echo "# Instalação concluída"
}

function installMaven() {
  mkdir -p ~/.tmp_maven && cd ~/.tmp_maven
  echo "# Baixando"
  wget -c "http://ftp.unicamp.br/pub/apache/maven/maven-3/3.6.3/binaries/${APACHE_MAVEN}" -q --show-progress
  echo "# Descompactando"
  tar -xzf $APACHE_MAVEN
  rm -rf *.tar.gz
  echo "# Instalando"
  sudo rm -rf /opt/maven
  sudo mv apache-* /opt/maven
  sudo chown -R $USER /opt/maven
  echo "# Adicionando à variável no ambiente"
  wget "${DOTFILES}/maven/path.txt" -qO- >>"${HOME}/.zshrc"
  mkdir -p $HOME/.m2 && wget "${DOTFILES}/maven/settings.xml" -qO $HOME/.m2/settings.xml
  echo "# Limpando arquivos desnecessários"
  rm -rf ~/.tmp_maven
  echo "# Instalação concluída"
}

function installVirtualBox() {
  sudo pacman -S virtualbox-host-modules-arch virtualbox --noconfirm --needed --quiet
}

#installPkg $XFCE
#installPkg $EXTRA
#installPkg $DEV
#installIntellij
#installMaven
