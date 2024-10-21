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
    if [[ ! "$(basename "$2")" =~ $REGEX ]]; then
        echo "$(basename $2) doesnt match regex"
        return 1;
    fi
    FILE_MODE_DATE=$(stat -c %Y "$1")
    if [ -f "$2" ]; then
        BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -le "$BAK_FILE_DATE" ]]; then
            echo "WARNING: backup entry $2 is newer than $1; Should not happen"
            ((WARNINGS++))
            return 1;
        fi
    fi
    echo "cp -a $1 $2"
    ((FILES_UPDATED++))
    if [[ $CHECKING -eq 0 ]]; then
        cp -a "$1" "$2";
        return $?;
    fi
    return 0;
}


function cpprint_summary(){
    if [[ ! "$(basename "$2")" =~ $REGEX ]]; then
        echo "$(basename $2) doesnt match regex"
        return 1;
    fi
    FILE_MODE_DATE=$(stat -c %Y "$1")
    if [ -f "$2" ]; then
        BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -le "$BAK_FILE_DATE" ]]; then
            echo "WARNING: backup entry $2 is newer than $1; Should not happen"
            ((WARNINGS++))
            return 1;
        fi
        ((FILES_UPDATED++))
    else
        local file_size="$(stat -c %s "$1")"
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
