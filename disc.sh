#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
cd $SCRIPT_PATH

if [ $# -ne 1 ]; then
    echo "$0 <project> - Packages the project into ISO/QCOW2/VDI/VMDK with the given name"
    exit 1
fi

REAL_PROJECT_PATH=$(realpath "projects/$1")
PARENT_PROJECT_PATH=$(dirname "$REAL_PROJECT_PATH")

REAL_PROJECTS_PATH=$(realpath "$SCRIPT_PATH/projects")

if [ "$PARENT_PROJECT_PATH" != "$REAL_PROJECTS_PATH" ]; then
    echo "LFI attack patched: erroneous directory"
    exit 2
fi

if [ ! -d "$REAL_PROJECT_PATH" ]; then
    echo "Project not found: $1"
    exit 3
fi

wget -q -O /dev/null --spider http://google.com
ONLINE=$?

if [ $ONLINE -eq 0 ]; then
    echo "Online"
    if [ -f "d2vm" ]; then
        rm -rf d2vm || echo "Could not remove old copy of d2vm (is the script already running?)"
    fi
    VERSION=$(git ls-remote --tags https://github.com/linka-cloud/d2vm |cut -d'/' -f 3|tail -n 1)
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "amd64" || echo "arm64")
    curl -sL "https://github.com/linka-cloud/d2vm/releases/download/${VERSION}/d2vm_${VERSION}_${OS}_${ARCH}.tar.gz" | tar -xvz d2vm
else
    echo "Offline"
    if [ ! -f "d2vm" ]; then
        echo "An internet connection is required to download d2vm."
        echo "Project site: https://github.com/linka-cloud/d2vm/"
        exit 4
    else
        echo "d2vm binary located, however there is no internet connection."
        echo "Proceeding with previous binary"
    fi
fi

DISC_NAME=$(echo "$1" | sed -e 's/[^A-Za-z0-9._-]/_/g')
DISC_PATH_WITHOUT_EXTENSION=$(realpath "discs/$DISC_NAME")
set -x 
./d2vm build "$REAL_PROJECT_PATH" -f "$REAL_PROJECT_PATH/Dockerfile" -o "$DISC_PATH_WITHOUT_EXTENSION.qcow2" -s 500m
./d2vm build "$REAL_PROJECT_PATH" -f "$REAL_PROJECT_PATH/Dockerfile" -o "$DISC_PATH_WITHOUT_EXTENSION.vdi" -s 500m
./d2vm build "$REAL_PROJECT_PATH" -f "$REAL_PROJECT_PATH/Dockerfile" -o "$DISC_PATH_WITHOUT_EXTENSION.raw" -s 500m
./d2vm build "$REAL_PROJECT_PATH" -f "$REAL_PROJECT_PATH/Dockerfile" -o "$DISC_PATH_WITHOUT_EXTENSION.vmdk" -s 500m
