#!/bin/bash


source ./utils.sh

CHECKING="0"

if [[ ! -d "$1" ]]; then
    echo "placeHolder"
    exit 1;
fi
WORKDIR="$1"
BACKUP="$2"
if [[ ! -d "$BACKUP" ]]; then
    mkdirprint "$BACKUP";
fi

for file in "$WORKDIR"/*; do
    if [[ -d $file ]]; then
        echo "1"
        continue;
    fi
    cpprint $file "$BACKUP/$(basename $file)"
done

WORKDIR=$1;

