#!/bin/bash

## handles messages for actions
## use 'init' to print something as initiated and then use 'end' for when it ends

function init() {
    echo -en "${1}..."
}

function end() {
    echo " ${1:-done}"
}