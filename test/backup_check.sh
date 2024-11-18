#!/bin/bash

function check_content() {
    for file in "$1"/*; do
        local basename=$(basename "$file")
        local simpler_name_workdir="${1#$(dirname "$WORKDIR")/}"
        if [[ ! -r "$file" ]]; then
            echo "ERROR: "$simpler_name_workdir"/"$basename" doesnt have read permissions"
            continue;
        fi
        if [[ -d "$file" ]]; then
            check_content "$file" "$2/$(basename  "$file")"
        fi
        if [[ ! -f "$2"/"$basename" ]];then 
            continue
        fi
        local simpler_name_backup="${2#$(dirname "$BACKUP")/}"
        if [[ ! -r "$2"/"$basename" ]]; then
            echo "ERROR: "$simpler_name_backup"/"$basename" doesnt have read permissions"
            continue;
        fi
        local original_hash=$(md5sum "$file" | awk '{ print $1 }')
        local backup_hash=$(md5sum "$2/$basename" | awk '{ print $1 }')
        if [[ "$original_hash" != "$backup_hash" ]]; then
            echo ""$simpler_name_workdir"/"$basename" "$simpler_name_backup"/"$basename" differ"
        fi
    done
}

if [[ ! $# -eq 2 ]]; then
    echo "ERROR: The function has two arguments"
    exit 1
elif [[ ! -d "$1" ]]; then
    echo "ERROR: "$(basename "$1")" is not a directory"
    exit 1;
elif [[ ! -d "$2" ]]; then
    echo "ERROR: "$(basename "$2")" is not a directory"
    exit 1;
fi

WORKDIR="$(realpath "$1")"
BACKUP="$(realpath "$2")"

if [[ ! -r "$1" ]]; then
    echo "ERROR: "$(basename "$WORKDIR")" doesnt have read permissions"
    exit 1
elif [[ ! -r "$2" ]]; then
    echo "ERROR: "$(basename "$BACKUP")" doesnt have read permissions"
    exit 1
fi

shopt -s nullglob dotglob

check_content "$WORKDIR" "$BACKUP"
