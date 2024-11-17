#!/bin/bash
function imprime_msg()
{
    date
    hostname
    echo "$USER"
    echo "A minha primeira funcao"
    return 0
}
imprime_msg
