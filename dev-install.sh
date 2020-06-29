#!/usr/bin/env sh

set -o errexit
set -o pipefail

# source config.sh
source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-cvc/master/config.sh)

function install_developer_tools() {
  for i in "${developer_tools[@]}"; do
    echo "+ Instalando: ${i}"
    yay -S ${i} --needed --noconfirm --quiet &>/dev/null
  done
}

function install_docker() {
  echo "+ Instalando o Docker e Docker Compose"
  yay -S docker docker-compose --needed --noconfirm --quiet
  echo "+ Adicionado o ${USER} ao grupo do docker"
  sudo usermod -aG docker $USER
  echo "+ Modificando o range de IP's para não conflitar com os ambientes de QA da CVC"
  sudo systemctl start docker.service
  sudo wget "${dotfiles_url}/docker/daemon.json" -qO /etc/docker/daemon.json
  sudo systemctl restart docker.service
  echo "+ Instalação concluída."
}

function install_intellij() {
  mkdir -p ~/.tmp_intellij && cd ~/.tmp_intellij
  echo "+ Baixando"
  wget -c "https://download.jetbrains.com/idea/${intellij_version}" -q --show-progress
  echo "+ Descompactando"
  tar -xzf $intellij_version
  echo "+ Instalando"
  sudo mv idea-* /opt/intellij-ultimate
  sudo chown -R $USER /opt/intellij-ultimate
  bash /opt/intellij-ultimate/bin/idea.sh &
  echo "+ Limpando arquivos desnecessários"
  rm -rf ~/tmp_intellij
  echo "+ Instalação concluída"
}

function install_maven() {
  mkdir -p ~/.tmp_maven && cd ~/.tmp_maven
  echo "# Baixando"
  wget -c "http://ftp.unicamp.br/pub/apache/maven/maven-3/3.6.3/binaries/${maven_version}" -q --show-progress
  echo "# Descompactando"
  tar -xzf $maven_version
  rm -rf *.tar.gz
  echo "# Instalando"
  sudo rm -rf /opt/maven
  sudo mv apache-* /opt/maven
  sudo chown -R $USER /opt/maven
  echo "# Adicionando à variável no ambiente"
  wget "${dotfiles_url}/maven/path.txt" -qO- >>"${HOME}/.zshrc"
  mkdir -p "${HOME}/.m2" && wget "${dotfiles_url}/maven/settings.xml" -qO "${HOME}/.m2/settings.xml"
  echo "# Limpando arquivos desnecessários"
  rm -rf ~/.tmp_maven
  echo "# Instalação concluída"
}

function setup_almundo() {
  sudo echo "127.0.0.1   dev.almundo.com.ar" >>/etc/hosts
}

clear
install_developer_tools
install_docker
install_intellij
install_maven
setup_almundo
