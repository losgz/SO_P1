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
            cpprint2 "$file" "$2/$(basename "$file")"
        fi
    done
}

function backup_delete() {
    for file in "$2"/*; do
        if [[ -d "$file" ]]; then
            backup_delete "$file" "$2/$(basename "$file")"
        else 
            if [[ ! -f "$1/$(basename "$file")" ]]; then
                (( SIZE_REMOVED+=$(stat -c %s "$file") ))
                ((FILES_DELETED++))
                echo "rm $file"
                if [[ $CHECKING -eq "0" ]]; then
                    rm "$file"
                fi
            fi
        fi
    done

}

function check_regex() {
    local regex="$1"
    local test_string=""
    if [[ "$test_string" =~ $regex ]]; then
        echo "Valid regex"
    elif [[ $? -eq 2 ]]; then
        echo "Invalid Regex"
        exit 1
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
            mapfile -t DIRS < "$DIRS_FILE"
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
        echo "$WORKDIR is a parent to $BACKUP"
        ((ERRORS++))
        summary
        exit 1
    fi
    BACKUP_PATH="$(dirname "$BACKUP_PATH")"
done

if [[ -z $DIRS_FILE ]]; then
    backup "$WORKDIR" "$BACKUP"
    backup_delete "$WORKDIR" "$BACKUP"
else
    n=${#DIRS[@]}
    for ((i=0;i < n; i++)); do
        backup "${DIRS[i]}" "$BACKUP"
        backup_delete "${DIRS[i]}" "$BACKUP"
    done
fi

summary
