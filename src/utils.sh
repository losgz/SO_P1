#!/bin/bash

function mkdirprint(){
    if [[ $CHECKING -eq 0 ]]; then
        mkdir "$1";
    fi
    echo "mkdir $1"
    return 0;
}

function summary() {
    echo "While backign $(basename "$WORKDIR"): $ERRORS ERRORS; $WARNINGS WARNINGS; $FILES_UPDATED Updated; $FILES_COPIED Copied; $FILES_DELETED Deleted"
}

function cpprint(){
    FILE_MODE_DATE=$(stat -c %Y "$1")
    if [[ "$(basename "$2")" =~ $FILE_FILTER ]]; then
        if [[ -f $2 ]]; then
            BAK_FILE_DATE=$(stat -c %Y "$2")
            if [[ "$FILE_MODE_DATE" -gt "$BAK_FILE_DATE" ]]; then
                if [[ $CHECKING -eq 0 ]]; then
                    cp -a "$1" "$2";
                fi
                echo "cp -a $1 $2"
                ((FILES_UPDATED++))
            else
                echo "WARNING: backup entry $2 is newer than $1; Should not happen"
                ((WARNINGS++))
            fi
        else
            if [[ $CHECKING -eq 0 ]]; then
                cp -a "$1" "$2";
            fi
            echo "cp -a $1 $2"
            ((FILES_COPIED++))
            return 0;
        fi
    else
        echo "$(basename $2) doen't match $FILE_FILTER"
    fi
    return 0;
}
