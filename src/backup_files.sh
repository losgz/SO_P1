#!/bin/bash

source ./utils.sh

#Variável usada para se verificar se a opção de checking foi selecionada
CHECKING="0"
WorkDir=""
Backup="" 

#Verificação das opções selecionadas
OPTERR=0 
while getopts "c" opt; do
    case $opt in
        c)
            CHECKING="1"
            ;;
        \?)
            echo "ERROR: Invalid option selected"
            exit 1
            ;;
    esac
done

# Move a posição dos parâmetros da linha de comando após o uso do getopts
shift $((OPTIND - 1))


if [[ $# -lt 2 ]]; then
    echo "ERROR: Not enough arguments"
    exit 1
elif [[ ! -d "$1" ]]; then
    echo "ERROR: "$1" not a directory"
    exit 1;
fi
WorkDir="$(realpath "$1")"

mkdirprint "$2" "$2";

Backup="$(realpath "$2")"
if [[ "$Backup" == "$WorkDir" ]]; then
    echo "ERROR: "$1" and "$2" are the same directory"
    exit 1
fi


# Calculate the total size of files in the source directory (in KB)
WorkDirSize=$(du -sk "$WorkDir" | awk '{print $1}')

if [[ -d "$2" ]]; then

    # Get available space in the destination directory (in KB)
    AvailableSpace=$(df -k "$Backup" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in destination directory."
        exit 1
    fi
else

    # Get available space in the computer (in KB)
    AvailableSpace=$(df -k "/" | awk 'NR==2 {print $4}')

    # Check if there's enough space in the destination directory
    if (( AvailableSpace < WorkDirSize )); then
        echo "ERROR: Not enough space in the computer."
        exit 1
    fi

fi

shopt -s nullglob dotglob
for file in "$2"/*; do
    if [[ -f "$1/$(basename "$file")" ]]; then
        continue;
    fi
    if [[ $CHECKING -eq "0" ]]; then
        rm "$file"
    fi
done

for file in "$WorkDir"/*; do
    if [[ -d "$file" ]]; then
        continue;
    fi
    cpprint "$file" "$Backup/$(basename "$file")"
done

