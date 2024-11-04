#!/bin/bash


source ./utils.sh


CHECKING="0"

while getopts "c" opt; do
    case $opt in
        c)
            CHECKING="1"
            ;;
    esac
done

shift $((OPTIND - 1))

if [[ ! -d "$1" ]]; then
    echo "$1 not a dir"
    exit 1;
fi
WORKDIR="$(realpath "$1")"

BACKUP="$(realpath "$2")"
if [[ ! -d "$BACKUP" ]]; then
    mkdirprint "$BACKUP";
fi
for file in "$WORKDIR"/*; do
    if [[ -d "$file" ]]; then
        continue;
    fi
    cpprint "$file" "$BACKUP/$(basename "$file")"
done

if [[ ! -d "$2" ]]; then
    return 0;
fi
for file in "$2"/*; do
    if [[ -f "$1/$(basename "$file")" ]]; then
        continue;
    fi
    if [[ $CHECKING -eq "0" ]]; then
        rm "$file"
    fi
done
