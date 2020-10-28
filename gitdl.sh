#!/bin/bash
# shellcheck disable=SC2015

SETUP_REPOSITORY=""

set -e

PATH=$PATH:/sbin:/usr/sbin:$HOME/go/bin:/usr/local/go/bin:$HOME/gittools:$HOME/bin:$HOME/.cargo/bin:$HOME/.local/bin

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

edebug() {
    if [ debug = true ]; then
        echo -e "[${YELLOW}DEBU${NC}]${YELLOW} $*${NC}"
    fi
}

# ────────────────────────────────────────────────────────────────────────────────

main() {
    verify_admin
}
