#!/bin/bash
function compare()
{
    if [ $1 = $2 ]; then
	return 0
    elif [ $1 -lt $2 ]; then
	return 1
    else
	return -1
    fi
}
compare $1 $2
