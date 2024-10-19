#!/bin/bash

function mkdirprint(){
    if [[ $CHECKING -eq 0 ]]; then
        mkdir "$1";
    fi
    echo "mkdir $1"
    return 0;
}

function cpprint(){

    FILE_MODE_DATE=$(stat -c %Y "$1")
    if [[ -f $2 ]]; then
        BAK_FILE_DATE=$(stat -c %Y "$2")
        if [[ "$FILE_MODE_DATE" -gt "$BAK_FILE_DATE" ]]; then
            if [[ $CHECKING -eq 0 ]]; then
                cp -a "$1" "$2";
            fi
            echo "cp -a $1 $2"
        else
            echo "$2 is newer than $1"
        fi
    else
        if [[ $CHECKING -eq 0 ]]; then
            cp -a "$1" "$2";
        fi
        echo "cp -a $1 $2"
        return 0;
    fi
    return 0;
}
