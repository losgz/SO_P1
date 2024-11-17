#!/bin/bash

source ./utils.sh

function backup() {
    # Variables for Summary
    local ERRORS="0"
    local WARNINGS="0"
    local FILES_UPDATED="0"
    local FILES_COPIED="0"
    local FILES_DELETED="0"
    local SIZE_COPIED="0"
    local SIZE_REMOVED="0"
    if [ ! -r "$1" ]; then
        echo "ERROR: "${1#$(dirname "$WORKDIR")/}" doenst have reading permissions"
        ((ERRORS++))
        summary "$1" "$ERRORS" "$WARNINGS" "$FILES_UPDATED" "$FILES_COPIED" "$SIZE_COPIED" "$FILES_DELETED" "$SIZE_REMOVED"
        return 1;
    elif [ ! -w "$2" ]; then
        echo "ERROR: "${2#$(dirname "$BACKUP")/}" doenst have writing permissions"
        ((ERRORS++))
        summary "$1" "$ERRORS" "$WARNINGS" "$FILES_UPDATED" "$FILES_COPIED" "$SIZE_COPIED" "$FILES_DELETED" "$SIZE_REMOVED"
        return 1;
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
        local file_copy="$2/$(basename "$file")"
        cpprint "$file" "$file_copy"
        local ret=$?
        if [[ $ret -eq  0 ]]; then
            ((FILES_COPIED++))
            ((SIZE_COPIED+=$(stat -c %s "$file")))
        elif [[ $ret -eq  1 ]]; then
            ((FILES_UPDATED++))
        elif [[ $ret -eq  3 ]]; then
            ((WARNINGS++))
        elif [[ $ret -eq  4 ]]; then
            ((ERRORS++))
        fi
    done
    if [[ ! -d "$2" ]]; then
        summary "$1" "$ERRORS" "$WARNINGS" "$FILES_UPDATED" "$FILES_COPIED" "$SIZE_COPIED" "$FILES_DELETED" "$SIZE_REMOVED"
        return 0;
    fi

    for file in "$2"/*; do
        if is_in_list "$file" "$DIRS_SET" ; then
            continue;
        fi
        if [ ! -w "$file" ]; then
            echo "ERROR: "${file#$(dirname "$BACKUP")/}" doenst have writing permissions"
            ((ERRORS++))
            continue;
        fi
        if [[ -d "$file" ]]; then
            if [[ ! -d "$1/$(basename "$file")" ]]; then
                local directory_size=$(( $(du -sk "$file" | awk '{print $1}') * 1024 ))
                ((SIZE_REMOVED+=$directory_size))
                local file_count=$(find "$file" -type f | wc -l)
                ((FILES_DELETED+=$file_count))
                if [[ $CHECKING -eq "0" ]]; then
                    rm -rf "$file"
                fi
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

    summary "$1" "$ERRORS" "$WARNINGS" "$FILES_UPDATED" "$FILES_COPIED" "$SIZE_COPIED" "$FILES_DELETED" "$SIZE_REMOVED"
}

function summary() {
    local simpler_name="${1#$(dirname "$WORKDIR")/}"
    #echo -e "While backing "$simpler_name": $2 Errors; $3 Warnings; $4 Updated; $5 Copied (${6}B); $7 Deleted (${8}B)\n"
    echo "While backuping "$simpler_name": $2 Errors; $3 Warnings; $4 Updated; $5 Copied (${6}B); $7 Deleted (${8}B)"
}

# Variables for the opts
CHECKING="0"
DIRS_FILE=""
REGEX=""
DIRS=()
WORKDIR=""
BACKUP=""
ARG_ERRORS="0"
declare -A DIRS_SET

while getopts ":cb:r:" opt; do
    case $opt in
        c)
            CHECKING="1"
            ;;
        b)
            DIRS_FILE="$OPTARG"
            if [[ ! -f $DIRS_FILE || ! -r $DIRS_FILE ]]; then
                echo "ERROR: $DIRS_FILE isn't a valid file"
                ((ARG_ERRORS++))
                continue
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
                ((ARG_ERRORS++))
            fi
            ;;
        \?)
            echo "ERROR: -$OPTARG is an invalid option"
            ((ARG_ERRORS++))
            ;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument."
            ((ARG_ERRORS++))
            ;;
    esac
done

shift $((OPTIND - 1))

if [[ ! -d "$1" ]]; then
    ((ARG_ERRORS++))
    echo "ERROR: "$(basename "$1")" is not a directory"
    summary "$1" "$ARG_ERRORS" "0" "0" "0" "0" "0" "0"
    exit 1;
fi

WORKDIR="$(realpath "$1")"

if [[ ! $# -eq 2 ]]; then
    echo "ERROR: The function has two arguments"
    ((ARG_ERRORS++))
fi
if [[ ! $ARG_ERRORS -eq 0 ]]; then
    summary "$WORKDIR" "$ARG_ERRORS" "0" "0" "0" "0" "0" "0"
    exit 1
fi

mkdirprint "$2" "$2";


BACKUP="$(realpath "$2")"
BackupPath="$BACKUP"

if [[ ! -r "$1" ]]; then
    echo "ERROR: "$(basename "$WORKDIR")" doesnt have read permissions"
    summary "$WORKDIR" "1" "0" "0" "0" "0" "0" "0"
    exit 1
fi

if [[ -d "$2" ]] && [[ ! -w "$2" ]]; then
    echo "ERROR: "$(basename "$BACKUP")" doesnt have write permissions"
    summary "$WORKDIR" "1" "0" "0" "0" "0" "0" "0"
    exit 1
fi

# Calculate the total size of files in the source directory (in KB)
WorkDirSize=$(du -sk "$WORKDIR" 2>/dev/null | awk '{print $1}')

dirToCheck="$BACKUP"
if [[ ! -d "$2" ]]; then
    dirToCheck="$(dirname "$BackupPath")" 
fi

# Get available space in the destination directory (in KB)
AvailableSpace=$(df -k "$dirToCheck" | awk 'NR==2 {print $4}')

# Check if there's enough space in the destination directory
if (( AvailableSpace < WorkDirSize )); then
    echo "ERROR: Not enough space in destination directory."
    exit 1
fi

while [[ "$BackupPath" != "/" ]]; do
    if [[ $WORKDIR == $BackupPath ]]; then
        echo "ERROR: "$(basename "$WORKDIR")" is parent of "$(basename "$BACKUP")""
        summary "$(basename "$WORKDIR")" "1" "0" "0" "0" "0" "0" "0"
        exit 1
    fi
    BackupPath="$(dirname "$BackupPath")"
done

for dir in "${DIRS[@]}"; do
    expanded_dir=$(eval echo "$dir")
    DIRS_SET["$(realpath "$expanded_dir")"]=1
done

shopt -s nullglob dotglob
backup "$WORKDIR" "$BACKUP"
exit 0
