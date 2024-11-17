#!/bin/bash

function fileSort(){
    if [ ! -f $1  ]; then
	echo "My guy thats not a file"
	return 1;
    fi
    mapfile -t nums < "$1"
    for ((i=1; i<${#nums[@]}; i++)); do
    	for ((j=i; j<${#nums[@]}; j++)); do
	    j0=$((j-1))
	    if [[ ${nums[j0]} -gt ${nums[j]} ]]; then
		first=${nums[$j0]}
		nums[$j0]=${nums[j]}
		nums[$j]=$first
    	    fi
    	done
    done
    echo vals ${nums[@]}
}
fileSort $1
