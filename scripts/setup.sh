#!/bin/bash

set -o errexit
set -o pipefail


########################
### MAIN FUNCTION ###
########################

main() {

    detect_terminal_capabilities  
    print_header
    echo
    is_utf_term
    sleep 2
    echo
    is_term_color
    sleep 2
    echo
    echo "Checking if the script is running as root or can use sudo..."
    check_root
    sleep 2
    echo
    echo "Root/sudo check complete."
    echo
    echo "Detecting the operating system..."
    echo
    detect_os
    sleep 2
    echo -e "Operating system detected: ${os_color}${os}${C_END}"
    echo 
    sleep 2
    echo
    install_all_the_dependencies
    echo
    install_python
    sleep 2
    echo
    install_docker
    sleep 2
    echo
    install_awscli
    echo
    sleep 2
    install_terraform
    sleep 2
    echo
    install_kubectl
    sleep 2
    echo
    install_helm
    echo
    sleep 2
    echo
    echo
    echo -e "${C_LGREEN}${TXT_CHECK} Setup complete.${C_END}"
}
########################
### BASE FUNCTIONS ###
########################

check_character_support() {
    local char="$1"
    echo -e "$char" | grep -q "$char"
}

is_utf_term() {
    if check_character_support "√"; then
    TXT_CHECK="✓"
    TXT_BEGIN="▶"
    TXT_SUB="▷"
    TXT_STAR="★"
    TXT_X="✗"
    TXT_INPUT="✍"
    else
    TXT_CHECK="+"
    TXT_BEGIN=">>"
    TXT_SUB=">"
    TXT_STAR="*"
    TXT_X="x"
    TXT_INPUT=" ::"
    fi
}

is_term_color() {
  if [[ $TERM == *"256"* ]]; then
    C_RED="\033[31m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_BLUE="\033[34m"
    C_WHITE="\033[37m"
    C_PURPLE="\033[35m"
    C_CYAN="\033[36m"
    C_ORANGE="\033[38;5;214m"

    C_LRED="\033[91m"
    C_LGREEN="\033[92m"
    C_LYELLOW="\033[93m"
    C_LBLUE="\033[94m"
    C_LORANGE="\033[38;5;215m"
    C_LRED="\033[38;5;203m"

    C_BOLD="\033[1m"
    C_ITALICS="\033[3m"
    C_BG_GREY="\033[100m"
    C_END="\033[0m"
  else
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_WHITE=""
    C_PURPLE=""
    C_CYAN=""
    C_ORANGE=""

    C_LRED=""
    C_LGREEN=""
    C_LYELLOW=""
    C_LBLUE=""
    C_LORANGE=""
    C_LRED=""

    C_BOLD=""
    C_ITALICS=""
    C_BG_GREY=""
    C_END=""
  fi
}

# Terminal detection for non-interactive environments
detect_terminal_capabilities() {
    if [ -t 1 ]; then
    # Interactive terminal detected
    is_utf_term
    is_term_color
    else
    # Non-interactive environment (e.g., CI/CD, cron)
    TXT_CHECK="OK"
    TXT_BEGIN=">>"
    TXT_SUB=">"
    TXT_STAR="*"
    TXT_X="X"
    TXT_INPUT="::"


    C_CYAN=""
    C_PURPLE=""
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_WHITE=""
    C_GREY=""
    C_LRED=""
    C_LGREEN=""
    C_LYELLOW=""
    C_LBLUE=""
    C_LORANGE=""
    C_LRED=""
    C_BOLD=""
    C_ITALICS=""
    C_BG_GREY=""
    C_END=""
    fi
}

print_header() {
    echo -e "${C_LBLUE}"
    cat << '_EOF_'
                             _
    ____                    (_)
   / __ \     _   _   _ __   _
  / / _` |   | | | | | '__| | |
 | | (_| |   | |_| | | |    | |
  \ \__,_|    \__,_| |_|    |_|
   \____/



_EOF_
    echo -e "${C_END}"
    echo
    echo "OS-ready script"
    echo
    echo -e "Copyright (C) 2024-2025 ${C_BOLD}uri${C_END} <${C_BG_GREY}${C_CYAN}https://github.com/Uritassa${C_END}>"
    echo
}



# Check if the user is root or not
check_root() {
  if [[ $EUID -ne 0 ]]; then
    if [[ ! -z "$1" ]]; then
      SUDO='sudo -E -H'
    else
      SUDO='sudo -E'
    fi
  else
    SUDO=''
  fi
}

detect_os() {
  if grep -qs "ubuntu" /etc/os-release; then
    os="ubuntu"
    os_color=${C_LORANGE:-""}
    os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
    if [[ "$os_version" -lt 2004 ]]; then
        echo "Use Ubuntu 20.04 or higher to use this installer."
        exit 1
    fi
  elif [[ -e /etc/debian_version ]]; then
    os="debian"
    os_color=${C_LRED:-""}
    os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
    if [[ "$os_version" -lt 11 ]]; then
        echo "Use Debian 11 or higher to use this installer."
        exit 1
    fi
  elif [[ -e /etc/fedora-release || -e /etc/almalinux-release ]]; then
    if [[ -e /etc/fedora-release ]]; then
        os="fedora"
        os_color=${C_CYAN:-""}
        os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
    else
        os="almalinux"
        os_color=${C_GREEN:-""}
        os_version=$(grep -oE '[0-9]+' /etc/almalinux-release | head -1)
    fi
    if [[ "$os_version" -lt 35 ]]; then
        echo "Use Fedora 35/AlmaLinux 8 or higher to use this installer."
        exit 1
    fi
  else
    echo "Unsupported operating system: $(uname -a)"
    exit 1
  fi
}

install_packages_debian_ubuntu() {
    REQUIRED_PACKAGES=(
        net-tools
        sudo
        curl
        wget
        git
        unzip
        rsync
        zip
        unzip
    )
    export DEBIAN_UBUNTU_FRONTEND=noninteractive
    echo -e "${C_CYAN}${TXT_BEGIN} Installing dependencies...${C_END}"
    $SUDO apt update -y;
    $SUDO apt-get -o Dpkg::Options::="--force-confold" -fuy install "${REQUIRED_PACKAGES[@]}"
    if [ $? -ne 0 ]; then
        echo -e "${C_RED}${TXT_BEGIN} Error during dependency installation.${C_END}"
        exit 1
    fi
    echo -e "${C_LGREEN}${TXT_BEGIN} Dependencies installed.${C_END}"
    unset DEBIAN_FRONTEND
}

install_dependencies_fedora() {
    check_root
    REQUIRED_PACKAGES=(
        sudo
        bind-utils
        curl
        wget
        git
        rsync
        zip
        unzip
    )   
    echo -e "${C_CYAN}${TXT_BEGIN} Installing dependencies...${C_END}"
    $SUDO dnf update -y
    $SUDO dnf install -y "${REQUIRED_PACKAGES[@]}"
    if [ $? -ne 0 ]; then
        echo -e "${C_RED}${TXT_BEGIN} Error during dependency installation.${C_END}"
        exit 1
    fi
    echo -e "${C_LGREEN}${TXT_BEGIN} Dependencies installed.${C_END}"
}

install_all_the_dependencies() {
  if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
    install_packages_debian_ubuntu
  elif [[ "$os" == "fedora" ]]; then
    install_dependencies_fedora
  else
    echo "Unsupported operating system: $os"
    exit 1
  fi
}

install_python() {
    echo -e "${C_LYELLOW}${TXT_BEGIN} Installing Python...${C_END}"
    if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
        export DEBIAN_FRONTEND=noninteractive
        $SUDO apt install -y python3 python3-venv python3-pip python3-setuptools
        unset DEBIAN_FRONTEND
    elif [[ "$os" == "fedora" ]]; then
        $SUDO dnf install -y python3 python3-pip python3-virtualenv python3-setuptools
    fi
    echo -e "${C_LGREEN}${TXT_CHECK} Python installed successfully.${C_END}"
}

install_docker() {
  echo -e "${C_LBLUE}${TXT_BEGIN} Installing Docker...${C_END}"

  if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
    export DEBIAN_FRONTEND=noninteractive

    $SUDO apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Remove existing keyring file if it exists
    if [[ -f /usr/share/keyrings/docker-archive-keyring.gpg ]]; then
      $SUDO rm /usr/share/keyrings/docker-archive-keyring.gpg
    fi

    curl -fsSL https://download.docker.com/linux/${os}/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${os} \
      $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

    $SUDO apt-get update
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io

    # Reset DEBIAN_FRONTEND
    unset DEBIAN_FRONTEND

  elif [[ "$os" == "fedora" ]]; then
    $SUDO dnf -y remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

    $SUDO dnf -y install dnf-plugins-core
    $SUDO dnf config-manager \
        --add-repo \
        https://download.docker.com/linux/fedora/docker-ce.repo

    $SUDO dnf install -y docker-ce docker-ce-cli containerd.io
    $SUDO systemctl start docker
    $SUDO systemctl enable docker
  fi

  echo -e "${C_LGREEN}${TXT_CHECK} Docker installed successfully.${C_END}"
}


install_kubectl() {
  echo -e "${C_LBLUE}${TXT_BEGIN} Installing kubectl...${C_END}"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  $SUDO install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  echo -e "${C_LGREEN}${TXT_CHECK} kubectl installed successfully.${C_END}"
}

install_awscli() {
    echo -e "${C_LORANGE}${TXT_BEGIN} Installing awscli...${C_END}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    $SUDO ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    echo -e "${C_LGREEN}${TXT_CHECK} awscli installed successfully.${C_END}"
}

install_terraform() {
    echo -e "${C_PURPLE}${TXT_BEGIN} Installing terraform...${C_END}"
    if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
        export DEBIAN_FRONTEND=noninteractive
        $SUDO apt install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        $SUDO tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
        gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        $SUDO tee /etc/apt/sources.list.d/hashicorp.list
        $SUDO apt update
        $SUDO apt install -y terraform
        unset DEBIAN_FRONTEND
    elif [[ "$os" == "fedora" ]]; then
        $SUDO dnf install -y dnf-plugins-core
        $SUDO dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        if ! $SUDO dnf -y install terraform; then
            echo -e "${C_RED}Repository installation failed. Attempting manual installation...${C_END}"
            wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
            unzip terraform_1.5.5_linux_amd64.zip
            $SUDO mv terraform /usr/local/bin/
            rm terraform_1.5.5_linux_amd64.zip
        fi
    fi

    echo -e "${C_LGREEN}${TXT_CHECK} Terraform installed successfully.${C_END}"
}

install_helm() {
    echo -e "${C_CYAN}${TXT_BEGIN} Installing Helm...${C_END}"
    if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
        export DEBIAN_FRONTEND=noninteractive
        curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
        $SUDO apt-get install apt-transport-https -y
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | $SUDO tee /etc/apt/sources.list.d/helm-stable-debian.list
        $SUDO apt-get update && $SUDO apt-get install helm -y
        unset DEBIAN_FRONTEND
    elif [[ "$os" == "fedora" ]]; then
        $SUDO dnf install helm -y
    fi
    echo -e "${C_LGREEN}${TXT_CHECK} Helm installed successfully.${C_END}"
}


main "$@"