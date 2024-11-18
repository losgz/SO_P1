#!/bin/bash

function mkdirprint(){
    if [[ -d "$1" ]]; then
        return 0
    fi
    local simpler_name="${1#$(dirname "$2")/}"
    echo "mkdir "$simpler_name""
    if [[ $CHECKING -eq 0 ]]; then
        mkdir "$1" 2>/dev/null
        return $?;
    fi
    return 0;
}

function cpprint(){
    local simpler_name_workdir="${1#$(dirname "$WORKDIR")/}"
    local simpler_name_backup="${2#$(dirname "$BACKUP")/}"
    if [ ! -r "$1" ]; then
        echo "ERROR: "$simpler_name_workdir" doenst have permission to read"
        return 4
    fi
    local retValue="0"
    if [ -f "$2" ]; then
        if [ ! -w "$2" ]; then
            echo "ERROR: "$simpler_name_backup" doenst have permission to write"
            return 4
        fi
        local FILE_MODE_DATE=$(stat -c %Y "$1")
        local BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -lt "$BAK_FILE_DATE" ]]; then
            echo "WARNING: backup entry $simpler_name_backup is newer than $simpler_name_workdir; Should not happen"
            return 3;
        elif [[ "$FILE_MODE_DATE" -eq "$BAK_FILE_DATE" ]]; then
            return 2;
        fi
        retValue="1"
    fi
    echo "cp -a $simpler_name_workdir $simpler_name_backup"
    if [[ $CHECKING -eq 0 ]]; then
        cp -a "$1" "$2";
    fi
    return $retValue
}

function is_in_list(){
    local real_arg="$(realpath "$1")"
    [[ -n "${DIRS_SET[$real_arg]}" ]]
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
