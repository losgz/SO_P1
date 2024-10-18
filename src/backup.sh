#!/bin/bash

source ./utils.sh

function backup() {
    if [[ ! -d "$2" ]]; then
        mkdirprint "$2";
    fi
    for file in "$1"/*; do
        if [[ -d "$file" ]]; then
            backup "$file" "$2/$(basename "$file")"
        else 
            cpprint "$file" "$2/$(basename "$file")"
        fi
    done
}

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
    echo "placeHolder"
    exit 1;
fi

if [[ ! -d "$2" ]]; then
    mkdirprint "$2";
fi


WORKDIR="$(realpath "$1")"
BACKUP="$(realpath "$2")"
BACKUP_PATH="$BACKUP"

while [[ "$BACKUP_PATH" != "/" ]]; do
    if [[ $WORKDIR == $BACKUP_PATH ]]; then
        echo "WORKDIR is parent"
        exit 1
    fi
    BACKUP_PATH="$(dirname "$BACKUP_PATH")"
done

backup "$WORKDIR" "$BACKUP"
