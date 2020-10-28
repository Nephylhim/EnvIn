#!/bin/bash
# shellcheck disable=SC2015

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

cmdExists() {
    command -v "$1" >/dev/null 2>&1
    return $?
}

fileExists() {
    if [[ -f $1 ]]; then
        return 0
    else
        return $?
    fi
}

dirExists() {
    if [[ -d $1 ]]; then
        return 0
    else
        return $?
    fi
}

# check() {
#     if $1; then
#         eok "$2"
#     else
#         efail "$3"
#     fi
# }

verify_admin() {
    # if groups "$USER" | grep -q sudo; then
    einfo "Verifying user is sudo. You may have to enter your sudo password"
    if sudo true; then
        eok "User is sudoer"
    else
        efail "User is not sudoer. This script must use sudo to work properly"
    fi
}

verifyCmd() {
    cmd=$1
    if [[ $2 != "" ]]; then
        pkg=$2
    else
        pkg=$1
    fi
    edebug "Verifying cmd $cmd is installed"
    edebug "Package name: $pkg"

    if cmdExists "$cmd"; then
        eok "$cmd installed"
    else
        edebug "Command not installed, installing it"
        install "$pkg"
    fi
}

verifyCargoCmd() {
    cmd=$1
    if [[ $2 != "" ]]; then
        crate=$2
    else
        crate=$1
    fi
    edebug "Verifying cmd $cmd is installed"
    edebug "Crate name: $crate"

    if cmdExists "$cmd"; then
        eok "$cmd installed"
    else
        edebug "Command not installed, installing it"
        cargoInstall "$crate"
    fi
}

install() {
    einfo "$* not installed. Installing..."
    sudo apt install -y "$@"
    eok "Installation successful: $*"
}

cargoInstall() {
    einfo "$* not installed. Installing..."
    cargo install "$@"
    eok "Installation successful: $*"
}

ensureDconfValue() {
    local reg=$1
    local expected=$2

    local val
    val=$(dconf read "$reg")
    if [[ "$val" == "$expected" ]]; then
        eok "dconf reg correctly setup $reg"
    else
        einfo "dconf reg $reg not correctly setup. changing value"
        dconf write "$reg" "$expected"

        val=$(dconf read "$reg")
        if [[ "$val" == "$expected" ]]; then
            eok "dconf reg correctly setup $reg"
        else
            efail "dconf reg not correctly setup. $reg shoud be $expected (got $val)"
            return 1
        fi
    fi
}

ensureDconfDirValues() {
    local dir=$1
    local expectedResults=("${@:2}")

    # echo ""
    # echo "*: $*"
    # echo "dconf dir: $dir"
    # echo "dconf expected results: ${expectedResults[*]}"

    local dve
    for dve in "${expectedResults[@]}"; do
        dvar=$(cut -d':' -f1 <<<"$dve")
        expected=$(cut -d':' -f2 <<<"$dve")

        # echo "should be: $dvar -> $expected"
        ensureDconfValue "${dir}${dvar}" "$expected"
    done
}

# ────────────────────────────────────────────────────────────────────────────────

installOhMyZSH() {
    einfo "Oh My Zsh not installed. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    eok "Installation successful: Oh My Zsh"
}

installCargo() {
    einfo "cargo not installed. Installing rust env..."
    curl https://sh.rustup.rs -sSf | sh
    eok "Installation successful: rust env"
}

installStarship() {
    einfo "starship not installed. Installing starship..."
    curl -fsSL https://starship.rs/install.sh | bash
    eok "Installation successful: starship"
}

ensureTilixConfiguration() {
    dt='/com/gexperts/Tilix/'
    dtv=("terminal-title-style:'small'" "use-tabs:true" "theme-variant:'dark'" "control-scroll-zoom:true" "new-instance-mode:'new-session'" "window-style:'disable-csd-hide-toolbar'")

    dtk="${dt}keybindings/"
    dtkv=("app-shortcuts:'F1'" "app-preferences:'<Primary><Shift>Escape'" "win-switch-to-previous-session:'<Primary><Shift>Tab'" "win-switch-to-next-session:'<Primary>Tab'" "session-switch-to-previous-terminal:''" "session-switch-to-next-terminal:''")

    dtpid=$(dconf list ${dt}profiles/ | head -n1)
    dtp="${dt}profiles/$dtpid"
    dtpv=("background-color:'#2E2E34343636'" "palette:['#2E2E34343636', '#CCCC00000000', '#4E4E9A9A0606', '#C4C4A0A00000', '#34346565A4A4', '#ADAD4040DFDF', '#060698209A9A', '#D3D3D7D7CFCF', '#555557575353', '#EFEF29292929', '#8A8AE2E23434', '#FCFCE9E94F4F', '#72729F9FCFCF', '#ADAD7F7FA8A8', '#3434E2E2E2E2', '#EEEEEEEEECEC']" "use-theme-colors:false" "cursor-shape:'ibeam'" "text-blink-mode:'unfocused'" "use-system-font:false" "font:'DroidSansMono Nerd Font Mono 12'")

    ensureDconfDirValues "$dt" "${dtv[@]}"
    ensureDconfDirValues "$dtk" "${dtkv[@]}"
    ensureDconfDirValues "$dtp" "${dtpv[@]}"
}

ensureGnomeConfiguration() {
    # keyboard layouts
    inputsourcesPath='/org/gnome/desktop/input-sources/'
    inputsourcesValues=("sources:[('xkb', 'us+intl'), ('xkb', 'fr')]" "mru-sources:[('xkb', 'us+intl'), ('xkb', 'fr')]" "xkb-options:@as []")
    ensureDconfDirValues "$inputsourcesPath" "${inputsourcesValues[@]}"

    # touchpad
    touchpadPath='/org/gnome/desktop/peripherals/touchpad/'
    touchpadValues=("natural-scroll:false" "tap-to-click:true")
    ensureDconfDirValues "$touchpadPath" "${touchpadValues[@]}"

    # mouse
    mousePath='/org/gnome/desktop/peripherals/mouse/'
    mouseValues=("natural-scroll:false")
    ensureDconfDirValues "$mousePath" "${mouseValues[@]}"

    # keybindings
    keybindingsPath='/org/gnome/desktop/wm/keybindings/'
    keybindingsValues=("move-to-workspace-up:['<Shift><Super>Up']" "move-to-workspace-1:['<Shift><Super>exclam']" "move-to-workspace-2:['<Shift><Super>at']" "move-to-workspace-3:['<Shift><Super>numbersign']" "move-to-workspace-4:['<Shift><Super>dollar']" "move-to-workspace-5:['<Shift><Super>percent']" "move-to-workspace-6:['<Shift><Super>dead_circumflex']" "move-to-workspace-7:['<Shift><Super>ampersand']" "move-to-workspace-8:['<Shift><Super>asterisk']" "move-to-workspace-9:['<Shift><Super>parenright']" "switch-to-workspace-1:['<Super>1']" "switch-to-workspace-2:['<Super>2']" "switch-to-workspace-3:['<Super>3']" "switch-to-workspace-4:['<Super>4']" "switch-to-workspace-5:['<Super>5']" "switch-to-workspace-6:['<Super>6']" "switch-to-workspace-7:['<Super>7']" "switch-to-workspace-8:['<Super>8']" "switch-to-workspace-9:['<Super>9']" "switch-to-workspace-down:['<Primary><Super>Down']" "move-to-monitor-down:@as []" "move-to-workspace-down:['<Shift><Super>Down']" "toggle-on-all-workspaces:['<Super>Return']" "move-to-monitor-up:@as []" "switch-to-workspace-up:['<Primary><Super>Up']")
    ensureDconfDirValues "$keybindingsPath" "${keybindingsValues[@]}"

    # keyboard conf
    keyboardPath='/org/gnome/settings-daemon/peripherals/keyboard/'
    keyboardValues=("numlock-state:'on'")
    ensureDconfDirValues "$keyboardPath" "${keyboardValues[@]}"

    # custom keybindings
    mediakeysPath='/org/gnome/settings-daemon/plugins/media-keys/'
    mediakeysValues=("custom-keybindings:['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']")
    ensureDconfDirValues "$mediakeysPath" "${mediakeysValues[@]}"
    custom0Path='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/'
    custom0Values=("binding:'<Super>t'" "command:'tilix'" "name:'tilix'")
    ensureDconfDirValues "$custom0Path" "${custom0Values[@]}"
    custom1Path='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/'
    custom1Values=("binding:'<Primary>dead_grave'" "command:'tilix --quake'" "name:'tilix quake'")
    ensureDconfDirValues "$custom1Path" "${custom1Values[@]}"
}

# ────────────────────────────────────────────────────────────────────────────────

main() {
    debug=false

    verify_admin

    # CLI utils
    echo -e "\n### CLI utils"
    verifyCmd "curl"
    verifyCmd "wget"
    verifyCmd "vim"
    verifyCmd "git"
    verifyCmd "jq"
    verifyCmd "tree"
    verifyCmd "ping" "iputils-ping"
    verifyCmd "rg" "ripgrep"
    verifyCmd "/usr/bin/fdfind" "fd-find"

    # Rust CLI utils
    echo -e "\n### Rust CLI utils"
    cmdExists "cargo" && eok "cargo installed" || installCargo
    verifyCargoCmd "exa"
    verifyCargoCmd "bat" "--locked bat"
    verifyCargoCmd "eva"
    verifyCargoCmd "delta" "git-delta"
    verifyCargoCmd "watchexec"
    verifyCargoCmd "dot" "--git https://github.com/ubnt-intrepid/dot.git"

    # Shell
    echo -e "\n### Shell"
    verifyCmd "tilix"
    ensureTilixConfiguration
    verifyCmd "zsh"
    dirExists "$HOME/.oh-my-zsh" && eok "oh-my-zsh installed" || installOhMyZSH
    cmdExists "starship" && eok "starship installed" || installStarship

    # Config
    echo -e "\n### Configuration"
    dirExists "$HOME/opt" && eok "local opt directory exists" || mkdir -p "$HOME/opt"
    dirExists "$HOME/bin" && eok "local bin directory exists" || mkdir -p "$HOME/bin"

    # TODO: dotfiles / synced files
    # install dot
    # dot init Nephylhim/dotfiles
    # dot link
    # dot check
    # TODO: git config

    # TODO: my tools
    # TEST: cargo bins
    # GO bins
    # go get -u github.com/charmbracelet/glow
    # TEST: gnome configuration / keybindings (via dconf / gsettings)
    # TODO: regarder gsettings
    # TODO: gnome tweak tools + extensions + conf bureaux
    # TEST: clavier us-int + fr (/org/gnome/desktop/input-sources/ ?)
    # verifyCmd "code" # Installed w/ dpkg by retrieving deb file on website
    # TODO: retrieve last version of vscode
    # TODO: vscode conf + extensions
    # TODO: fonts (fixed mono font)
}

main
