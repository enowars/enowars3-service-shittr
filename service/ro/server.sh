#!/bin/bash
export PATH="$(pwd)/bin:$PATH"

source urls.sh
source utils.sh

pageTimeStart

declare -A INHDR=()
declare -a OUTHDR=(
    "Server: Shittr"
    "X-Frame-Options: sameorigin"
    "X-XXE-Protection: 1;prevent"
    "X-Content-Type: nosniff"
    "Content Type: 1337/5P34K"
)
declare -A STATUS=(
   [1337]="WORKS FOR ME"
   [302]="TRY AGAIN"
   [403]="GTFO"
   [404]="NOPE"
   [4242]="IT BURNS!!!"
)
declare -A PARAMS=()
declare -A TPLPARAMS=()

debug() {
    echo "$(date), $SOCAT_PEERADDR $@" | tee -a "$LOGPATH" >&2
}
addOutHdr() {
    OUTHDR+=("$1: $2")
}
addInHdr() {
    local IFS=':'
    read -r -a p <<< "$1"
    if [ -n "${p[0]}" -a -n "${p[1]}" ]
    then
        INHDR+=(["${p[0]}"]="${p[1]}")
    fi
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
            break 
        fi
        addInHdr "$hdrLine"
    done
}

parseBody() {
    read -d '' -r -n "${INHDR['Content-Length']}" body
    if [ ! -n "$body" ]
    then 
        return 
    fi
    local IFS='&'
    read -r -a ps <<< "$body"
    for kv in "${ps[@]}"
    do
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

    if [ "$RMETH" = "GET" ]
    then 
        parseParams
    elif [ "$RMETH" = "POST" ]
    then 
        parseBody
    elif [ "$RMETH" = "HEAD" ]
    then 
        return 
    fi

    for mw in "${MIDDLEWARES[@]}"
    do 
        $mw
    done
}

matchURI() {
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
            return 
        fi
    done
    answer 404 "GTFO"
}

routeURI() {
    if [ "$RMETH" = "GET" ]
    then 
        matchURI GURLS
    elif [ "$RMETH" = "POST" ]
    then 
        matchURI PURLS
    elif [ "$RMETH" = "HEAD" ]
    then 
        matchURI HURLS
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
    # echo
    # echo 
    if [ -n "$c" ]
    then
        echo "$c"
    else
        echo
    fi
    exit 0
}

error() {
    if [ $# -eq 1 ]
    then
        answer 4242 "n0p3, $1"
    else
        answer 4242 "n0p3"
    fi
    exit 1
}

doRender() {
    local t="$1"
    if [ ! -f "./templates/$t" ]
    then
        error
    fi
    for k in "${!TPLPARAMS[@]}"
    do
        if [ -z "$k" ]
        then
            continue 
        fi
        local v="${TPLPARAMS[$k]}"
        local -n r="$k"
        r="$v"
    done
    source "./templates/$t"
}

clearUserCache() {
    find "$CACHEDIR" -type f -iname "*-$1.cache" -delete
}

clearPageCache() {
    find "$CACHEDIR" -type f -iname "$1-*.cache" -delete
}

render() {
    if [ 1 -eq $CACHE -a -z "$NOCACHE" ]
    then
        local c="${FUNCNAME[1]}"
        local r="$(doRender $*)"
        if [ ! "$c" = "source" ]
        then
            local u=$(([ -n "$USER" ] && echo "$USER" || echo "anonymous") | md5sum | cut -d' ' -f 1)
            echo "$r" | tee "$CACHEDIR/$c-$u.cache"
        else
            echo "$r"
        fi
    else
        doRender $*
    fi
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

parseRequest

routeURI