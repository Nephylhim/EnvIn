#!/bin/bash

set -e

RED=$'\e[01;31m'
GREEN=$'\e[1;32m'
BLUE=$'\e[1;34m'
# YELLOW=$'\e[33m'
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
# ────────────────────────────────────────────────────────────────────────────────

# dt='/com/gexperts/Tilix/'
# dtv=('terminal-title-style' 'use-tabs' 'theme-variant' 'control-scroll-zoom' 'new-instance-mode' 'window-style')

# for dvar in "${dtv[@]}"; do
#     val=$(dconf read "${dt}${dvar}")
#     echo "\"$dvar:$val\""
# done

# dtpid=$(dconf list ${dt}profiles/ | head -n1)
# # echo "dconf tilix profile id: $dtpid"

# dtp="/com/gexperts/Tilix/profiles/$dtpid"
# # echo "dconf tilix profile path: $dtp"

# dtpv=('background-color' 'palette' 'use-theme-colors' 'cursor-shape' 'text-blink-mode' 'use-system-font' 'font')

# for dvar in "${dtpv[@]}"; do
#     val=$(dconf read "${dtp}${dvar}")
#     echo "\"$dvar:$val\""
# done

# dconf read /com/gexperts/Tilix/theme-variant
# dconf read /com/gexperts/Tilix/terminal-title-style
# dconf read /com/gexperts/Tilix/use-tabs
# dconf read /com/gexperts/Tilix/control-scroll-zoom
# dconf read /com/gexperts/Tilix/new-instance-mode
# dconf read /com/gexperts/Tilix/window-style

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

dt='/com/gexperts/Tilix/'
dtv=("terminal-title-style:'small'" "use-tabs:true" "theme-variant:'dark'" "control-scroll-zoom:true" "new-instance-mode:'new-session'" "window-style:'disable-csd-hide-toolbar'")

dtk="${dt}keybindings/"
dtkv=("app-shortcuts:'F1'" "app-preferences:'<Primary><Shift>Escape'" "win-switch-to-previous-session:'<Primary><Shift>Tab'" "win-switch-to-next-session:'<Primary>Tab'" "session-switch-to-previous-terminal:''" "session-switch-to-next-terminal:''")

dtpid=$(dconf list ${dt}profiles/ | head -n1)
dtp="${dt}profiles/$dtpid"
dtpv=("background-color:'#2E2E34343636'" "palette:['#2E2E34343636', '#CCCC00000000', '#4E4E9A9A0606', '#C4C4A0A00000', '#34346565A4A4', '#ADAD4040DFDF', '#060698209A9A', '#D3D3D7D7CFCF', '#555557575353', '#EFEF29292929', '#8A8AE2E23434', '#FCFCE9E94F4F', '#72729F9FCFCF', '#ADAD7F7FA8A8', '#3434E2E2E2E2', '#EEEEEEEEECEC']" "use-theme-colors:false" "cursor-shape:'ibeam'" "text-blink-mode:'unfocused'" "use-system-font:false" "font:'DroidSansMono Nerd Font Mono 12'")

# echo "dconf tilix profile id: $dtpid"
# echo "dconf tilix profile path: $dtp"

# for dve in "${dtv[@]}"; do
#     dvar=$(cut -d':' -f1 <<<"$dve")
#     expected=$(cut -d':' -f2 <<<"$dve")
#     val=$(dconf read "${dt}${dvar}")
#     # echo "\"$dvar:$val\""
#     if [[ "$val" == "$expected" ]]; then
#         eok "Tilix var $dvar correctly setup"
#         # true
#     else
#         # efail "Tilix var $dvar shoud be $expected (got $val)"
#         einfo "Tilix var $dvar not correctly setup. changing value"
#         dconf write "${dt}${dvar}" "$expected"
#     fi
# done

# for dve in "${dtpv[@]}"; do
#     dvar=$(cut -d':' -f1 <<<"$dve")
#     expected=$(cut -d':' -f2 <<<"$dve")
#     val=$(dconf read "${dtp}${dvar}")
#     # echo "\"$dvar:$val\""
#     if [[ "$val" == "$expected" ]]; then
#         eok "Tilix var $dvar correctly setup"
#         # true
#     else
#         # efail "Tilix var $dvar shoud be $expected (got $val)"
#         einfo "Tilix var $dvar not correctly setup. changing value"
#         dconf write "${dtp}${dvar}" "$expected"
#     fi
# done

# for dve in "${dtkv[@]}"; do
#     dvar=$(cut -d':' -f1 <<<"$dve")
#     expected=$(cut -d':' -f2 <<<"$dve")
#     val=$(dconf read "${dtk}${dvar}")
#     # echo "\"$dvar:$val\""
#     if [[ "$val" == "$expected" ]]; then
#         eok "Tilix var $dvar correctly setup"
#         # true
#     else
#         # efail "Tilix var $dvar shoud be $expected (got $val)"
#         einfo "Tilix var $dvar not correctly setup. changing value"
#         dconf write "${dtk}${dvar}" "$expected"
#     fi
# done

ensureDconfDirValues "$dt" "${dtv[@]}"
ensureDconfDirValues "$dtk" "${dtkv[@]}"
ensureDconfDirValues "$dtp" "${dtpv[@]}"
