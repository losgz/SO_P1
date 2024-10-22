#!/bin/bash

function check_content() {
    for file in "$1"/*; do
        if [[ -d "$file" ]]; then
            check_content "$file" "$2/$(basename  "$file")"
        fi
        local basename=$(basename "$file")
        local original_hash=$(md5sum "$file" | awk '{ print $1 }')
        local backup_hash=$(md5sum "$2/$basename" | awk '{ print $1 }')
        if [[ "$original_hash" != "$backup_hash" ]]; then
            echo "$1/$basename $2/$basename differ"
        fi
    done
}

WORKDIR="$(realpath "$1")"
BACKUP="$(realpath "$2")"

check_content "$WORKDIR" "$BACKUP"
