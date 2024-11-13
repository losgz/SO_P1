#!/bin/bash

source ./utils.sh

function backup() {
    for file in "$1"/{*,.*}; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            mkdirprint "$2/$(basename "$file")";
            backup "$file" "$2/$(basename "$file")"
            continue;
        elif [[ ! "$(basename "$file")" =~ $REGEX ]]; then
            continue;
        fi
        cpprint_summary "$file" "$2/$(basename "$file")"
    done
}

function backup_delete() {
    if [[ ! -d "$2" || ! -n "$2" ]]; then
        return 0;
    fi
    for file in "$2"/{*,.*}; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            local directory=$file
            backup_delete "$1/$(basename "$file")" "$2/$(basename "$file")"
            if [[ ! -d "$1/$(basename "$file")" && $CHECKING -eq "0" ]]; then
                rm -rf "$directory"
                continue;
            fi
            continue;
        fi 
        echo "-f "$1/$(basename "$file")""
        if [[ ! -f "$file" || -f "$1/$(basename "$file")" ]]; then
            continue;
        fi
        ((SIZE_REMOVED+=$(stat -c %s "$file") ))
        ((FILES_DELETED++))
        if [[ $CHECKING -eq "0" ]]; then
            rm "$file"
        fi
    done
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
                ((ERRORS++))
                summary
                exit 1
            fi
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
    echo "ERROR: "$(basename "$1")" is not a directory"
    ((ERRORS++))
    summary
    exit 1;
fi

if [[ ! -d "$2" ]]; then
    mkdirprint "$2";
fi


WorkDir="$(realpath "$1")"
Backup="$(realpath "$2")"
BackupPath="$Backup"

while [[ "$BackupPath" != "/" ]]; do
    if [[ $WorkDir == $BackupPath ]]; then
        echo "ERROR: "$(basename "$WorkDir")" is parent of "$(basename "$Backup")""
        ((ERRORS++))
        summary
        exit 1
    fi
    BackupPath="$(dirname "$BackupPath")"
done

shopt -s nullglob
backup "$WorkDir" "$Backup"
backup_delete "$WorkDir" "$Backup"

summary
