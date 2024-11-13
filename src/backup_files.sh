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
    echo "ERROR: "$1" not a directory"
    exit 1;
fi
WorkDir="$(realpath "$1")"

Backup="$(realpath "$2")"
if [[ "$Backup" == "$WorkDir" ]]; then
    echo "ERROR: "$1" and "$2" are the same directory"
    exit 1
fi
if [[ ! -d "$Backup" ]]; then
    mkdirprint "$Backup";
fi
for file in "$WorkDir"/{*,.*}; do
    if [[ -d "$file" ]]; then
        continue;
    fi
    cpprint "$file" "$Backup/$(basename "$file")"
done

if [[ ! -d "$2" ]]; then
    exit 0;
fi
for file in "$2"/{*,.*}; do
    if [[ -f "$1/$(basename "$file")" ]]; then
        continue;
    fi
    if [[ $CHECKING -eq "0" ]]; then
        rm "$file"
    fi
done
