#!/bin/bash

set -e

RED=$'\e[01;31m'
GREEN=$'\e[1;32m'
BLUE=$'\e[1;34m'
YELLOW=$'\e[33m'
NC=$'\e[0m'

einfo() {
    echo -e "[${BLUE}INFO${NC}] $*"
}

efail() {
    echo -e "[${RED}FAIL${NC}] $*"
}

eok() {
    echo -e "[${GREEN} OK ${NC}] $*"
}

ensureVSCodeExtensions() {
    extensions="$(code --list-extensions)"

    while IFS='' read -r extension || [[ -n "$extension" ]]; do
        if grep -qP '^(?:#|\/\/)' <<<"$extension"; then
            continue
        fi

        if [[ $extensions == *"${extension}"* ]]; then
            eok "Extension $extension is already installed"
        else
            einfo "Installing $extension"
            code --install-extension "$extension"
        fi
    done <'vscode_extensions.cfg'
}

ensureVSCodeExtensions
