#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/utils.sh

ensure_curl_install() {
    if ! command -v curl &> /dev/null; then
        echo "Curl is not installed. Installing curl..."
        
        if [[ $CURRENT_OS == $LINUX_GNU_OS ]]; then 
            apt update && apt install curl -y
        elif [[ $CURRENT_OS == $MAC_OS ]]; then
            echo "Curl should already be available on macOS. Please check your installation."
        else
            echo "Unsupported operating system. Exiting."
        fi
    fi
}

ensure_brew_install() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

ensure_docker_install() {
    if ! command -v docker &> /dev/null; then
        echo "Docker and plugins are not installed. Installing Docker and docker compose..."

        if [[ $CURRENT_OS == $LINUX_GNU_OS ]]; then
            
            # Add Docker's official GPG key:
            apt-get update
            apt-get install ca-certificates curl
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc

            # Add the repository to Apt sources:
            echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update

            apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            usermod -aG docker $USER
            systemctl restart docker
        elif [[ $CURRENT_OS == $MAC_OS ]]; then
            brew install docker docker-credential-helper docker-compose docker buildx colima

            mkdir -p ~/.docker/cli-plugins

            ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
            ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
            chmod +x ~/.docker/cli-plugins/docker-compose
            chmod +x ~/.docker/cli-plugins/docker-buildx

            colima start --cpu 6 --memory 8
        else
            echo "Unsupported operating system. Exiting."
            exit 1
        fi

        echo "WARNING: You will probably need to reboot to use docker with your current user."
    fi
}

ensure_git_install() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Installing git..."

        if [[ $CURRENT_OS == $LINUX_GNU_OS ]]; then 
            apt update && apt install git -y
        elif [[ $CURRENT_OS == $MAC_OS ]]; then
            brew install git
        else
            echo "Unsupported operating system. Exiting."
            exit 1
        fi
    fi

    read -p "Enter your username for git : " username
    read -p "Enter your email for git : " email 

    git config --global user.name "$username"
    git config --global user.email $email
}

ensure_ssh_key_exist() {
    ssh_key="$HOME/.ssh/id_ed25519.pub"

    if [ ! -f "$ssh_key" ]; then
        echo "The SSH public key does not exist. Generating a new key..."

        read -p "Enter your email address for the SSH key: " email 

        # Generate a new SSH key
        ssh-keygen -t ed25519 -C "$email"

        echo "SSH key generated. You need to add it to GitHub."

        # Display the instruction to copy the key
        echo -e "Display the SSH public key with the following command: \n"
        echo -e "cat $ssh_key \n"
        echo "Then, add it to your GitHub account."
        while true; do
            read -p "Did you had that key on your github account ? (yes/no): " confirm_git_ssh_key_added
            if [[ "$confirm_git_ssh_key_added" == "yes" ]]; then
                break
            elif [[ "$confirm_git_ssh_key_added" == "no" ]]; then
                echo "Please add it to continue, otherwise you can't end that script beacuse he need it."
            else
                echo "Please answer 'yes' or 'no'."
            fi
        done
    fi
}

bootstrap() {
    detect_os
    ensure_curl_install

    if [[ $CURRENT_OS == $MAC_OS ]]; then ensure_brew_install; fi

    ensure_docker_install
    ensure_git_install
    ensure_ssh_key_exist

    # Create network to interconnect Shopopop's project 
    docker network ls | grep shopopop_network > /dev/null || docker network create shopopop_network
}

bootstrap
