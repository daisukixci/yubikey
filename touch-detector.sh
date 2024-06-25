#!/usr/bin/env bash

# Stop on error.
set -e

# shellcheck disable=SC1091
source env.sh
source lib/install.sh

REPO="github.com/maximbaz/yubikey-touch-detector"

function install_pacman {
    sudo pacman -S yubikey-touch-detector
}

function install_go {
    #check if go version if >=1.17 as it changes the install procedure
    if [[ $(go version | cut -d' ' -f3 | cut -d'.' -f2) -ge 17 ]]; then
        go install "${REPO}@latest"
    else
        go get -u "${REPO}"
    fi
}

function service_start {
    cat <<EOF >"${XDG_CONFIG_HOME}/yubikey-touch-detector/service.conf"
# Configuration file for yubikey-touch-detector.service
# See yubikey-touch-detector(1) for more information
# enable debug logging
YUBIKEY_TOUCH_DETECTOR_VERBOSE=false

# show desktop notifications using libnotify
YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=true

# do not print notifications to stdout
YUBIKEY_TOUCH_DETECTOR_STDOUT=false

# disable Un*x socket notifier
YUBIKEY_TOUCH_DETECTOR_NOSOCKET=false
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now yubikey-touch-detector.service
}

case $TOUCH_DETECTOR in
"pacman")
    install_pacman
    ;;
"go")
    install_go
    ;;
*)
    echo "Sorry, your OS is not supported"
    exit 1
    ;;
esac
