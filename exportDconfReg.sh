#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Wrong number of arguments. Expect $0 <reg_dir_path>"
fi

echo -en "\n\n$(basename "$1")Path='$1'\n$(basename "$1")Values=("

space=0
for dvar in $(dconf list "$1"); do
    if [[ ${dvar: -1} == '/' ]]; then
        # if the last character is a '/', this means this is a directory and not a variable.
        # continue to the next var
        continue
    fi

    val=$(dconf read "$1$dvar")

    if [ $space -eq 1 ]; then
        echo -n " "
    fi
    echo -n "\"$dvar:$val\""

    space=1
done

echo ")"
echo "ensureDconfDirValues \"\$$(basename "$1")Path\" \"\${$(basename "$1")Values[@]}\""
