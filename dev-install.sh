#!/usr/bin/env sh

set -o errexit
set -o pipefail

source <(curl -s https://raw.githubusercontent.com/andreluizs/arch-dev/master/_common.sh)

function install_docker() {
  echo "+ Instalando o Docker e Docker Compose"
  yay -S docker docker-compose --needed --noconfirm --quiet
  echo "+ Adicionado o ${USER} ao grupo do docker"
  sudo usermod -aG docker $USER
  echo "+ Modificando o range de IP's para não conflitar com os ambientes de QA da CVC"
  sudo systemctl start docker.service
  sudo wget "${configs_url}/docker/daemon.json" -qO /etc/docker/daemon.json
  sudo systemctl restart docker.service
  echo "+ Instalação concluída."
}

function install_intellij() {
  local intellij_version="ideaIC-2020.3.3.tar.gz"
  mkdir -p ~/.tmp_intellij && cd ~/.tmp_intellij
  echo "+ Baixando"
  wget -c "https://download.jetbrains.com/idea/${intellij_version}" -q --show-progress
  echo "+ Descompactando"
  tar -xzf $intellij_version
  echo "+ Instalando"
  sudo mv idea-* /opt/intellij-community
  sudo chown -R $USER /opt/intellij-community
  bash /opt/intellij-community/bin/idea.sh &
  echo "+ Limpando arquivos desnecessários"
  rm -rf ~/tmp_intellij
  echo "+ Instalação concluída"
}

function install_maven() {
  local maven_version="apache-maven-3.6.3-bin.tar.gz"
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
  wget "${configs_url}/maven/path.txt" -qO- >>"${HOME}/.zshrc"
  echo "# Limpando arquivos desnecessários"
  rm -rf ~/.tmp_maven
  echo "# Instalação concluída"
}

function install_devtools() {
  local developer_tools="ttf-fira-code ttf-jetbrains-mono visual-studio-code-bin "
  developer_tools+="insomnia slack-desktop teams-insiders openfortigui mongodb-compass"
  echo "# Installing DevTools"
  yay -S ${developer_tools} --needed --noconfirm --quiet &>/dev/null
}

function install_zsh() {
  echo "# Installing zsh"
  yay -S zsh zsh-completions --needed --noconfirm --quiet
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}

function install_nvm() {
  echo "# Installing nvm"
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
}

clear
install_docker
install_intellij
install_maven
install_devtools
install_zsh
install_nvm
