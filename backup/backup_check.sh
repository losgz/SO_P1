#!/bin/bash

function check_content() {
    for file in "$1"/*; do
        if [[ -d "$file" ]]; then
            check_content "$file" "$2/$(basename  "$file")"
        fi
        local basename=$(basename "$file")
        #My guy pelo que percebi ele só tem de dizer se os ficheiros com o mesmo nome são diferentes 
        if [[ ! -f "$2"/"$basename" ]];then 
            #echo "$2/$basename doesn't exist"
            continue
        fi
        local original_hash=$(md5sum "$file" | awk '{ print $1 }')
        local backup_hash=$(md5sum "$2/$basename" | awk '{ print $1 }')
        local simpler_name_workdir="${1#$(dirname "$WORKDIR")/}"
        if [[ "$original_hash" != "$backup_hash" ]]; then
            echo ""${1#$(dirname "$WORKDIR")/}" "${2#$(dirname "$BACKUP")/}" differ"
        fi
    done
}

WORKDIR="$(realpath "$1")"
BACKUP="$(realpath "$2")"

check_content "$WORKDIR" "$BACKUP"
