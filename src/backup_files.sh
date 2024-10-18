#!/bin/bash


source ./utils.sh

CHECKING="0"

if [[ ! -d $1 ]]; then
    echo "placeHolder"
    exit 1;
fi
if [[ ! -d $2 ]]; then
    mkdirprint $2;
    echo $prev_command
fi
WORKDIR=$1;

