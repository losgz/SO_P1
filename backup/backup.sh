#!/bin/bash

source ./utils.sh

function backup() {
    if [[ ! -d "$2" ]]; then
        mkdirprint "$2";
    fi
    for file in "$1"/*; do
        if [[ -d "$file" ]]; then
            backup "$file" "$2/$(basename "$file")"
            continue;
        elif [[ ! "$(basename "$file")" =~ $REGEX ]]; then
            echo "$(basename $2) doesnt match regex"
            continue;
        fi
        cpprint "$file" "$2/$(basename "$file")"
    done
}

function backup_some() {
    if [[ ! -d "$2" ]]; then
        mkdirprint "$2";
    fi
    for file in "$1"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            backup "$file" "$2/$(basename "$file")"
        elif [[ ! "$(basename "$file")" =~ $REGEX ]]; then
            echo "$(basename $2) doesnt match regex"
            continue;
        fi
        cpprint "$file" "$2/$(basename "$file")"
    done
}

function backup_delete() {
    if [[ ! -d "$2" || ! -n "$2" ]]; then
        return 0;
    fi
    for file in "$2"/*; do
        if [[ -d "$file" ]]; then
            if [[ ! -d "$1/$(basename "$file")" ]]; then
                rm -rf "$file"
                continue;
            fi
            backup_delete "$1/$(basename "$file")" "$2/$(basename "$file")"
            continue;
        fi
        if [[ ! -f "$file" || -f "$1/$(basename "$file")" ]]; then
            continue;
        fi
        if [[ $CHECKING -eq "0" ]]; then
            rm "$file"
        fi
    done
}

function backup_delete_some() {
    if [[ ! -d "$2" || ! -n "$2" ]]; then
        return 0;
    fi
    for file in "$2"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            backup_delete "$file" "$2/$(basename "$file")"
            continue;
        fi 
        if [[ ! -f "$file" || -f "$1/$(basename "$file")" ]]; then
            continue;
        fi
        if [[ $CHECKING -eq "0" ]]; then
            rm "$file"
        fi
    done
}

# Variables for the opts
CHECKING="0"
DIRS_FILE=""
REGEX=""
DIRS=()
SIZE_COPIED="0"
SIZE_REMOVED="0"

while getopts "cb:r:" opt; do
    case $opt in
        c)
            CHECKING="1"
            ;;
        b)
            DIRS_FILE="$OPTARG"
            if [[ ! -f $DIRS_FILE || ! -r $DIRS_FILE ]]; then
                echo "$DIRS_FILE isn't a valid file"
                DIRS_FILE=""
            fi
            lines=()
            mapfile -t lines < "$DIRS_FILE"
            for line in "${lines[@]}"; do
                if [[ -e $(eval echo "$line") ]]; then
                    DIRS+=("$line")
                fi
            done
            ;;
        r)
            REGEX="$OPTARG"
            check_regex "$REGEX"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [[ ! -d "$1" ]]; then
    echo "$1 not a dir"
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

if [[ -z $DIRS_FILE ]]; then
    backup_delete "$WORKDIR" "$BACKUP"
    backup "$WORKDIR" "$BACKUP"
else
    backup_delete_some "$WORKDIR" "$BACKUP"
    backup_some "$WORKDIR" "$BACKUP"
fi