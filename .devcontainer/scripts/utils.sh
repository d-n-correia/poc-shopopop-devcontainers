#!/bin/bash

SCRIPT_DIR_UTILS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global var for OS type
CURRENT_OS=""
LINUX_GNU_OS="linux-gnu" # Ubuntu/Debian
MAC_OS="macOS"

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Ubuntu/Debian
        if command -v lsb_release &> /dev/null && [[ "$(lsb_release -is)" == "Ubuntu" ]]; then
            OS_TYPE=$LINUX_GNU_OS
        else
            OS_TYPE="linux" # (non-Ubuntu)
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE=$MAC_OS
    else
        OS_TYPE="Unknown"
    fi

    # Afficher le résultat du type de système d'exploitation
    echo "Le système d'exploitation détecté est : $OS_TYPE"
}

ensure_project_exist() {
    root_path="$SCRIPT_DIR_UTILS/../.."
    project_name=$1

    # Check if the project is missing
    if [ ! -d "$root_path/$project_name" ]; then
        echo "$1 project is missing. Cloning it from github..."
        cd $root_path && echo ${1} | xargs -n1 | xargs -I{} git clone git@github.com:Shopopop/{}
    fi
}