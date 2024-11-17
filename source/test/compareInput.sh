#!/bin/bash
function compare()
{
    read num1
    read num2
    if [ $num1 = $num2 ]; then
	return 0
    elif [ $num1 -lt $num2 ]; then
	return 1
    else
	return -1
    fi
}
compare
