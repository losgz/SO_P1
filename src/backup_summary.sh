#!/bin/bash

source ./utils.sh

function backup() {
    for file in "$1"/*; do
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

function new_backup() {
    # Variables for Summary
    local ERRORS="0"
    local WARNINGS="0"
    local FILES_UPDATED="0"
    local FILES_COPIED="0"
    local FILES_DELETED="0"
    local SIZE_COPIED="0"
    local SIZE_REMOVED="0"
    for file in "$1"/*; do
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
        if [[ $? -eq "0" ]]; then
            ((FILES_UPDATED++))
        else if [[ $? -eq "-1" ]]; then
            ((WARNINGS++))
        else 
            ((FILES_UPDATED++))
            SIZE_COPIED+=$?
        fi
    done
    new_backup_delete "$1" "$2"
    
    if [[ ! -d "$2" ]]; then
        return 0;
    fi

    for file in "$2"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            if [[ ! -d "$1/$(basename "$directory")" && $CHECKING -eq "0" ]]; then  
                rm -rf "$directory"
            fi
            continue;
        fi 
        if [[ -f "$1/$(basename "$file")" ]]; then
            continue;
        fi
        ((SIZE_REMOVED+=$(stat -c %s "$file") ))
        ((FILES_DELETED++))
        if [[ $CHECKING -eq "0" ]]; then
            rm "$file"
        fi
    done

    summary "$1" "$ERR"
}


function backup_delete() {
    if [[ ! -d "$2" || ! -n "$2" ]]; then
        return 0;
    fi
    for file in "$2"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
            continue;
        fi
        if [[ -d "$file" ]]; then
            local directory="$file"
            backup_delete "$1/$(basename "$file")" "$2/$(basename "$file")"
            if [[ ! -d "$1/$(basename "$directory")" && $CHECKING -eq "0" ]]; then  
                rm -rf "$directory"
            fi
            continue;
        fi 
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

# Variables for the opts
CHECKING="0"
DIRS_FILE=""
REGEX=""
DIRS=()

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
        ((ERRORS++))
        summary
        exit 1
    fi
    BackupPath="$(dirname "$BackupPath")"
done

shopt -s nullglob dotglob
backup "$WorkDir" "$Backup"
backup_delete "$WorkDir" "$Backup"

summary
