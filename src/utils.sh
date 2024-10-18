#!/bin/bash

function mkdirprint(){
    if [[ $CHECKING -eq 0 ]]; then
        mkdir "$1";
    fi
    echo "mkdir $1"
    return 0;
}

function cpprint(){
    if [[ $CHECKING -eq 0 ]]; then
        cp -a "$1" "$2";
    fi
    echo "cp -a $1 $2"
    return 0;
}
