#!/bin/bash

function mkdirprint(){
    echo "mkdir $1"
    if [[ $CHECKING -eq 0 ]]; then
        mkdir "$1";
        return $?;
    fi
    return 0;
}

function summary() {
    echo "While backign $(basename "$WORKDIR"): $ERRORS ERRORS; $WARNINGS WARNINGS; $FILES_UPDATED Updated; $FILES_COPIED Copied ($SIZE_COPIED B); $FILES_DELETED Deleted ($SIZE_REMOVED B)"
}

function cpprint(){
    local FILE_MODE_DATE=$(stat -c %Y "$1")
    if [ -f "$2" ]; then
        local BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -le "$BAK_FILE_DATE" ]]; then
            echo "WARNING: backup entry $2 is newer than $1; Should not happen"
            return 1;
        fi
    fi
    echo "cp -a $1 $2"
    if [[ $CHECKING -eq 0 ]]; then
        cp -a "$1" "$2";
        return $?;
    fi
    return 0;
}


function cpprint_summary(){
    local FILE_MODE_DATE=$(stat -c %Y "$1")
    if [ -f "$2" ]; then
        local BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -le "$BAK_FILE_DATE" ]]; then
            echo "WARNING: backup entry $2 is newer than $1; Should not happen"
            ((WARNINGS++))
            return 1;
        fi
        ((FILES_UPDATED++))
    else
        (( SIZE_COPIED+=$(stat -c %s "$1") ))
        ((FILES_COPIED++))
    fi
    echo "cp -a $1 $2"
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
        echo "Valid regex"
    elif [[ $? -eq 2 ]]; then
        echo "Invalid Regex"
        exit 1
    fi
}