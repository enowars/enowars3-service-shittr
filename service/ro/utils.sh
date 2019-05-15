#!/bin/bash

# https://stackoverflow.com/a/1683850/8957548
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

# https://stackoverflow.com/a/37840948/8957548
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# https://gist.github.com/cdown/1163649
urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

# https://stackoverflow.com/a/17841619/8957548
join_by() { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

# https://stackoverflow.com/a/11454477/8957548
enc() {
    read -r data
    echo "$data" | openssl enc -e -aes-128-ecb -nosalt -A -K $(cat "$ENCKEY") -a 2>/dev/null
}

dec() {
    read -r data
    echo "$data" | openssl enc -d -aes-128-ecb -nosalt -A -K $(cat "$ENCKEY") -a 2>/dev/null
}