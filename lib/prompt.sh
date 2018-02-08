#!/bin/bash

function prompt() {
    local default secret text variable value OPTIND
    while getopts ":d:v:st:" option; do
        case "$option" in
            d)
                default="$OPTARG" >&2
                ;;
            v)
                variable="$OPTARG" >&2
                ;;
            s)
                secret=1
                ;;
            t)
                text="$OPTARG" >&2
                ;;
            \?)
                echo "Invalid option -$OPTARG"
                exit 1
                ;;
        esac
    done
    until [[ -n $value ]]; do
        [[ -n $default ]] && text+=" (${default})"
        if [[ -n $secret ]]; then
            read -sp "${text^}: " value
            echo
        else
            read -p "${text^}: " value
        fi
        value=${value// /_};
        [[ -z $value ]] && value="$default"
    done
    eval "${variable}=$value"
}


function pick() {
    local directory linebreak options=() path quit variable text value="" OPTIND
    while getopts ":D:no:O:qv:t:" option; do
        case "$option" in
            D)
                if [[ -d $OPTARG ]]; then
                    directory="$OPTARG" >&2
                else
                    echo "Invalid directory: $OPTARG"
                    exit 1
                fi
                ;;
            n)
                linebreak=1
                ;;
            o)
                options+=("$OPTARG") >&2
                ;;
            O)
                for opt in $OPTARG; do
                    options+=("$opt")
                done
                ;;
            q)
                [[ -z $quit ]] && options=("quit" "${options[@]}")
                quit=1
                ;;
            v)
                variable="$OPTARG" >&2
                ;;
            t)
                text="$OPTARG" >&2
                ;;
            \?)
                echo "Invalid option -$OPTARG"
                exit 1
                ;;
        esac
    done
    PS3="${text^}: "
    if [[ -n $directory ]]; then
        original_directory=$directory
        until [[ -n $value ]]; do
            list_files=
            [[ "$original_directory" != "$directory" ]] && list_files=".. "
            list_files+=$( ls $directory )
            select path in $list_files; do
                if [[ ".." == "$path" ]]; then
                    directory=${directory%/*}
                elif [[ -n $path ]]; then
                    directory+="/${path}"
                fi
                break
            done
            [[ -f $directory ]] && value=$directory
        done
    else
        select value in "${options[@]}"; do
            break
        done
    fi
    echo "Selected '$value'"
    [[ -n $linebreak ]] && echo -en "\n"
    eval "${variable}=\"$value\""
}

