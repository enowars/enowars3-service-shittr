#!/bin/bash

declare -a INHDR=()
declare -a OUTHDR=(
    "Server: Bash0r"
    "X-Frame-Options: sameorigin"
    "x-xss-protection: 1; mode=block"
    "x-content-type: nosniff"
)
declare -A STATUS=(
   [200]="OK"
   [500]="Error"
   [302]="Moved Temporarily"
   [1337]="Lol"
)
declare -A PARAMS=()
declare -A TPLPARAMS=()

debug() {
    echo "$(date) $@" >&2
}
addOutHdr() {
    OUTHDR+=("$1: $2")
}
addInHdr() {
    INHDR+=("$1")
}
addParam() {
    local IFS='='
    read -r -a p <<< "$1"
    if [ -n "${p[0]}" -a -n "${p[1]}" ]
    then
        PARAMS+=(["${p[0]}"]="${p[1]}")
    fi
}
addTplParam() {
    TPLPARAMS+=(["$1"]="$2")
}

parseArgs() {
    local IFS=' '
    read -r -a p <<< "$1"
    RMETH="${p[0]}"
    RURL="${p[1]}"
    RVER="${p[2]}"
    debug "$RMETH"
    debug "$RURL"
    debug "$RVER"
    if [ -z "$RMETH" -o -z "$RURL" -o -z "$RVER" ]
    then
        exit 1
    fi
}

parseRegHdrs() {
    while read -r hdrLine; do
        hdrLine=${hdrLine%%$'\r'}
        if [ ! -n "$hdrLine" ]
        then
            return 
        fi
        #debug "$hdrLine"
        INHDR+=("$hdrLine")
    done
}

parseBody() {
    read -r body
    if [ ! -n "$body" ]
    then 
        return 
    fi
    local IFS='&'
    read -r -a ps <<< "$body"
    for kv in "${ps[@]}"
    do
        debug "$kv"
        addParam "$kv"
    done
}

parseParams() {
    p=${RURL#*\?}
    local IFS='&'
    read -r -a ps <<< "$p"
    for kv in "${ps[@]}"
    do
        debug "$kv"
        addParam "$kv"
    done
}

parseRequest() {
    read -r httpLine
    if [ ! $? -eq 0 ]
    then
        exit 1
    fi
    httpLine=${httpLine%%$'\r'}
    debug "$httpLine"

    parseArgs "$httpLine"
    debug "$RMETH, $RURL, $RVER"

    parseRegHdrs
    debug "${INHDR[@]}"

    if [ "$RMETH" = "GET" ]
    then 
        parseParams
    elif [ "$RMETH" = "POST" ]
    then 
        parseBody
        debug "${PARAMS[@]}"
    fi
}

matchURI() {
    source GET.sh
    local -n rs=$1
    debug "$rs"
    for r in "${!rs[@]}"
    do
        if [ -z "$r" ]
        then
            continue 
        fi
        if [[ "$RURL" =~ $r ]]
        then
            ${rs[$r]}
        fi
    done
}

routeURI() {
    if [ "$RMETH" = "GET" ]
    then 
        debug "GET"
        matchURI GURLS
    elif [ "$RMETH" = "POST" ]
    then 
        debug "POST"
        matchURI PURLS
    fi
}

answer() {
    s="$1"
    st="${STATUS[$s]}"
    c="$2"
    echo "HTTP/1.0 $s $st"
    for h in "${OUTHDR[@]}"
    do
        echo "$h"
    done
    echo
    if [ -n "$c" ]
    then
        echo "$c"
    else
        echo
    fi
}

error() {
    answer 500 "n0p3"
}

render() {
    local tplp="$1"
    if [ ! -f "./templates/$tplp" ]
    then
        error
    fi
    local tplc=$(cat "./templates/$tplp")

    for k in "${!TPLPARAMS[@]}"
    do
        if [ -z "$k" ]
        then
            continue 
        fi
        local v="${TPLPARAMS[$k]}"
        tplc="${tplc/\$\{$k\}/$v}"
    done
    echo "$tplc"
}

includeTpl() {
    if [ -f "./templates/$1" ]
    then
        addTplParam "$1" "$(render $1)"
    fi 
}

redirect() {
    addOutHdr "Location" "$1"
    answer 302 ""
}