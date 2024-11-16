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
    for file in "$1"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
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
        local simpler_name_workdir="${file#$(dirname "$WORKDIR")/}"
        local simpler_name_backup="${file_copy#$(dirname "$BACKUP")/}"
        local FILE_MODE_DATE=$(stat -c %Y "$file")
        if [ -f "$file_copy" ]; then
            local BAK_FILE_DATE=$(stat -c %Y "$file_copy")
            if [[ "$FILE_MODE_DATE" -lt "$BAK_FILE_DATE" ]]; then
                echo "WARNING: backup entry $simpler_name_backup is newer than $simpler_name_workdir; Should not happen"
                ((WARNINGS++))
                continue;
            elif [[ "$FILE_MODE_DATE" -eq "$BAK_FILE_DATE" ]]; then
                continue;
            fi
            ((FILES_UPDATED++))
        else
            ((FILES_COPIED++))
            ((SIZE_COPIED+=$(stat -c %s "$file")))
        fi
        echo "cp -a "$simpler_name_workdir" "$simpler_name_backup""
        if [[ $CHECKING -eq 0 ]]; then
            cp -a "$file" "$file_copy";
        fi
    done
    if [[ ! -d "$2" ]]; then
        summary "$1" "$ERRORS" "$WARNINGS" "$FILES_UPDATED" "$FILES_COPIED" "$SIZE_COPIED" "$FILES_DELETED" "$SIZE_REMOVED"
        return 0;
    fi

    for file in "$2"/*; do
        if is_in_list "$file" "${DIRS[@]}" ; then
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

# Variables for the opts
CHECKING="0"
DIRS_FILE=""
REGEX=""
DIRS=()
WORKDIR=""
BACKUP=""

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
                REGEX="(a"
            fi
            ;;
        \?)
            echo "ERROR: -$OPTARG is an invalid option"
            REGEX="(a"
            ;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument."
            REGEX="(a"
            ;;
    esac
done

shift $((OPTIND - 1))
if [[ $# -lt 2 ]]; then
    echo "ERROR: Not enough arguments"
    summary "$1" "1" "0" "0" "0" "0" "0" "0"
    exit 1
elif [[ ! -d "$1" ]]; then
    echo "ERROR: "$(basename "$1")" is not a directory"
    summary "$1" "1" "0" "0" "0" "0" "0" "0"
    exit 1;
fi

WORKDIR="$(realpath "$1")"
if [[ "$REGEX" == "(a" ]]; then
    summary "$WORKDIR" "1" "0" "0" "0" "0" "0" "0"
    exit 1
fi

mkdirprint "$2" "$2";


BACKUP="$(realpath "$2")"
BackupPath="$BACKUP"

# Calculate the total size of files in the source directory (in KB)
WorkDirSize=$(du -sk "$WORKDIR" | awk '{print $1}')

if [[ -d "$2" ]]; then

    # Get available space in the destination directory (in KB)
    AvailableSpace=$(df -k "$BACKUP" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in destination directory."
        summary "$(basename "$WORKDIR")" "1" "0" "0" "0" "0" "0" "0"
        exit 1
    fi
else

    # Get available space in the computer (in KB)
    AvailableSpace=$(df -k "/" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in the computer."
        summary "$(basename "$WORKDIR")" "1" "0" "0" "0" "0" "0" "0"
        exit 1
    fi
fi

while [[ "$BackupPath" != "/" ]]; do
    if [[ $WORKDIR == $BackupPath ]]; then
        echo "ERROR: "$(basename "$WORKDIR")" is parent of "$(basename "$BACKUP")""
        summary "$(basename "$WORKDIR")" "1" "0" "0" "0" "0" "0" "0"
        exit 1
    fi
    BackupPath="$(dirname "$BackupPath")"
done

declare -A DIRS_SET
for dir in "${DIRS[@]}"; do
    DIRS_SET["$(realpath "$dir")"]=1
done

shopt -s nullglob dotglob
backup "$WORKDIR" "$BACKUP"
echo $file_count
exit 0
