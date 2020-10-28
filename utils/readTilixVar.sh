#!/bin/bash

set -e

echo "########## Global"
dt='/com/gexperts/Tilix/'
dtv=('terminal-title-style' 'use-tabs' 'theme-variant' 'control-scroll-zoom' 'new-instance-mode' 'window-style')

for dvar in "${dtv[@]}"; do
    val=$(dconf read "${dt}${dvar}")
    echo "\"$dvar:$val\""
done

dtpid=$(dconf list ${dt}profiles/ | head -n1)
# echo "dconf tilix profile id: $dtpid"

dtp="/com/gexperts/Tilix/profiles/$dtpid"
# echo "dconf tilix profile path: $dtp"

echo -e "\n\n########## Profile"
dtpv=('background-color' 'palette' 'use-theme-colors' 'cursor-shape' 'text-blink-mode' 'use-system-font' 'font')

for dvar in "${dtpv[@]}"; do
    val=$(dconf read "${dtp}${dvar}")
    echo "\"$dvar:$val\""
done

echo -e "\n\n########## Keybindings"
dtk="${dt}keybindings/"

dtkv=('app-shortcuts' 'app-preferences' 'win-switch-to-previous-session' 'win-switch-to-next-session' 'session-switch-to-previous-terminal' 'session-switch-to-next-terminal')

for dvar in "${dtkv[@]}"; do
    val=$(dconf read "${dtk}${dvar}")
    echo "\"$dvar:$val\""
done
