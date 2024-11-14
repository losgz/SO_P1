#!/bin/bash

function mkdirprint(){
    if [[ -d "$1" ]]; then
        return 0
    fi
    local simpler_name="${1#$(dirname "$Backup")/}"
    echo "mkdir "$simpler_name""
    if [[ $CHECKING -eq 0 ]]; then
        mkdir "$1";
        return $?;
    fi
    return 0;
}

function summary() {
    local simpler_name="${1#$(dirname "$WorkDir")/}"
    echo -e "While backign $(basename "$simpler_name"): $2 ERRORS; $3 WARNINGS; $4 Updated; $5 Copied (${6}B); $7 Deleted (${8}B)\n"
}

function cpprint(){
    local simpler_name_workdir="${1#$(dirname "$WorkDir")/}"
    local simpler_name_backup="${2#$(dirname "$Backup")/}"
    local FILE_MODE_DATE=$(stat -c %Y "$1")
    if [ -f "$2" ]; then
        local BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -le "$BAK_FILE_DATE" ]]; then
            echo "WARNING: backup entry $simpler_name_backup is newer than $simpler_name_workdir; Should not happen"
            return 1;
        fi
    fi
    echo "cp -a $simpler_name_workdir $simpler_name_backup"
    if [[ $CHECKING -eq 0 ]]; then
        cp -a "$1" "$2";
        return $?;
    fi
    return 0;
}

function is_in_list(){
    local arg="$(realpath "$1")"
    shift
    local list=("$@")
    for item in "${list[@]}"; do
        if [[ $(realpath "$(eval echo "$item")") == $arg ]]; then
            return 0;
        fi
    done
    return 1;
}

function check_regex() {
    local regex="$1"
    local test_string=""
    if [[ "$test_string" =~ $regex ]]; then
        :
    elif [[ $? -eq 2 ]]; then
        echo "ERROR: Invalid Regex"
        return 1
    fi
    return 0
}