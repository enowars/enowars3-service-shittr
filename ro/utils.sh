#!/bin/bash

# https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

get_cookie() {
    local cookies="${INHDR[Cookie]}"
    local IFS=';'
    read -r -a cks <<< "$cookies"

    for ck in "${cks[@]}"
    do
        local IFS='='
        read -r -a c <<< "$ck"
        if [ "$1" = "$(trim ${c[0]})" ]
        then
            echo "$(trim ${c[1]})"
            break
        fi
    done
}

# https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
join_by() { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }