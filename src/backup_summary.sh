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

check_regex() {
    local regex="$1"
    local test_string=""
    if [[ "$test_string" =~ $regex ]]; then
        echo "Valid regex"
    else
        if [[ $? -eq 2 ]]; then
            exit 1
        fi
    fi
}

# Variables for Summary
ERRORS="0"
WARNINGS="0"
FILES_UPDATED="0"
FILES_COPIED="0"
FILES_DELETED="0"

# Variables for the opts
CHECKING="0"
DIRS_FILE=""
FILE_FILTER=""

while getopts "cb:r:" opt; do
    case $opt in
        c)
            CHECKING="1"
            ;;
        b)
            DIRS_FILE="$OPTARG"
            if [[ ! -f $DIRS_FILE || ! -r $DIRS_FILE ]]; then
                echo "$DIRS_FILE isn't a valid file"
                exit 1
            fi
            mapfile -t DIRS < "$DIRS_FILE"
            echo "${DIRS[@]}"
            ;;
        r)
            FILE_FILTER="$OPTARG"
            check_regex "$FILE_FILTER"
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
        echo "$WORKDIR is a parent to $BACKUP"
        ((ERRORS++))
        summary
        exit 1
    fi
    BACKUP_PATH="$(dirname "$BACKUP_PATH")"
done
if [[ ! -z $DIRS_FILE ]]; then
    backup "$WORKDIR" "$BACKUP"
else
    n=${#DIRS[@]}
    for ((i=0;i < n; i++)); do
        backup "${DIRS[i]}" "$BACKUP"
    done
fi

summary
