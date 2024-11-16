#!/bin/bash

source ./utils.sh

function backup() {
    if [[ ! -r "$1" ]]; then
        echo "ERROR: "${1#$(dirname "$WORKDIR")/}" doenst have permission to read"
        return 0
    fi
    for file in "$1"/*; do
        if is_in_list "$file" "$DIRS_SET" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            mkdirprint "$2/$(basename "$file")" "$BACKUP";
            backup "$file" "$2/$(basename "$file")"
            continue;
        elif [[ ! "$(basename "$file")" =~ $REGEX ]]; then
            continue;
        fi
        cpprint "$file" "$2/$(basename "$file")"
    done
    backup_delete "$1" "$2"
}

function backup_delete() {
    if [[ ! -d "$2" ]]; then
        return 0;
    fi
    if [[ ! -w "$2" ]]; then
        echo "ERROR: "${2#$(dirname "$BACKUP")/}" doenst have permission to write"
        return 0
    fi
    for file in "$2"/*; do
        if is_in_list "$file" "$DIRS_SET" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            if [[ ! -d "$1/$(basename "$file")" ]]; then
                if [[ $CHECKING -eq "0" ]]; then
                    rm -rf "$file"
                fi
            fi
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
WORKDIR=""
BACKUP=""
declare -A DIRS_SET

while getopts ":cb:r:" opt; do
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
            if [[ $? -eq 1 ]]; then
                exit 1
            fi
            ;;
        \?)
            echo "ERROR: -$OPTARG is an invalid option"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [[ $# -lt 2 ]]; then
    echo "ERROR: Not enough arguments"
    exit 1
elif [[ ! -d "$1" ]]; then
    echo "ERROR: "$(basename "$1")" is not a directory"
    exit 1;
fi

mkdirprint "$2" "$2";


WORKDIR="$(realpath "$1")"
BACKUP="$(realpath "$2")"
BackupPath="$BACKUP"

if [[ ! -r "$1" ]]; then
    echo "ERROR: "${1#$(dirname "$WORKDIR")/}" doenst have permission to read"
    exit 1
fi

if [[ ! -w "$2" ]]; then
    echo "ERROR: "${2#$(dirname "$BACKUP")/}" doenst have permission to write"
    exit 1
fi

# Calculate the total size of files in the source directory (in KB)
WorkDirSize=$(du -sk "$WORKDIR" | awk '{print $1}')

if [[ -d "$2" ]]; then

    # Get available space in the destination directory (in KB)
    AvailableSpace=$(df -k "$BACKUP" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in destination directory."
        exit 1
    fi
else

    # Get available space in the computer (in KB)
    AvailableSpace=$(df -k "/" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in the computer."
        exit 1
    fi
fi

while [[ "$BackupPath" != "/" ]]; do
    if [[ $WORKDIR == $BackupPath ]]; then
        echo "ERROR: "$(basename "$WORKDIR")" is parent of "$(basename "$BACKUP")""
        exit 1
    fi
    BackupPath="$(dirname "$BackupPath")"
done

for dir in "${DIRS[@]}"; do
    DIRS_SET["$(realpath "$dir")"]=1
done

shopt -s nullglob dotglob
backup "$WORKDIR" "$BACKUP"
