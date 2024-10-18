#!/bin/bash

trap 'prev_command=$last_command; last_command=$BASH_COMMAND' DEBUG

if [[ ! -d $1 ]]; then
    echo "placeHolder"
    exit 1;
fi
if [[ ! -d $2 ]]; then
    mkdir $2;
    echo $prev_command
fi
WORKDIR=$1;

