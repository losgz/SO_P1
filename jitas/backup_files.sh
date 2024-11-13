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

if [[ -d "$2" ]]; then
  
    # Calculate the total size of files in the source directory (in KB)
    WorkDirSize=$(du -sk "$WorkDir" | awk '{print $1}')

    # Get available space in the destination directory (in KB)
    AvailableSpace=$(df -k "$Backup" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in destination directory."
        exit 1
    fi
    shopt -s nullglob
    for file in "$2"/{*,.*}; do
        if [[ -f "$1/$(basename "$file")" ]]; then
            continue;
        fi
        if [[ $CHECKING -eq "0" ]]; then
            rm "$file"
        fi
    done
fi

for file in "$WorkDir"/{*,.*}; do
    if [[ -d "$file" ]]; then
        continue;
    fi
    cpprint "$file" "$Backup/$(basename "$file")"
done

