#!/bin/bash

source ./utils.sh

function backup() {
    for file in "$1"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            mkdirprint "$2/$(basename "$file")" "$Backup";
            backup "$file" "$2/$(basename "$file")"
            continue;
        elif [[ ! "$(basename "$file")" =~ $REGEX ]]; then
            continue;
        fi
        cpprint "$file" "$2/$(basename "$file")"
    done
}

function backup_delete() {
    if [[ ! -d "$2" ]]; then
        return 0;
    fi
    for file in "$2"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            if [[ ! -d "$1/$(basename "$file")" && $CHECKING -eq "0" ]]; then
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

# Variables for the opts
CHECKING="0"
DIRS_FILE=""
REGEX=""
DIRS=()
SIZE_COPIED="0"
SIZE_REMOVED="0"

OPTERR=0
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
            if [[ $? -eq 1 ]]; then
                exit 1
            fi
            ;;
        \?)
            echo "ERROR: Invalid option selected"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [[ ! $# -eq 2 ]]; then
    echo "ERROR: Not enough arguments"
    exit 1
elif [[ ! -d "$1" ]]; then
    echo "ERROR: "$(basename "$1")" is not a directory"
    exit 1;
fi

mkdirprint "$2" "$2";


WorkDir="$(realpath "$1")"
Backup="$(realpath "$2")"
BackupPath="$Backup"

# Calculate the total size of files in the source directory (in KB)
WorkDirSize=$(du -sk "$WorkDir" | awk '{print $1}')

if [[ -d "$2" ]]; then

    # Get available space in the destination directory (in KB)
    AvailableSpace=$(df -k "$Backup" | awk 'NR==2 {print $4}')

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
    if [[ $WorkDir == $BackupPath ]]; then
        echo "ERROR: "$(basename "$WorkDir")" is parent of "$(basename "$Backup")""
        exit 1
    fi
    BackupPath="$(dirname "$BackupPath")"
done
shopt -s nullglob dotglob
backup "$WorkDir" "$Backup"
backup_delete "$WorkDir" "$Backup"
