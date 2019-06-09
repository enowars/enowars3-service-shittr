#!/bin/bash

is_authenticated() {
    if valid_session "$(get_cookie 'auth')"; then
        AUTHENTICATED=1
        return 0
    else
        AUTHENTICATED=0
        return 1
    fi
}

get_request_user() {
    USER=$(get_user "$(get_cookie 'auth')")
}

is_admin() {
    if [[ "$USER" =~ "admin" && -n "$DEBUG" ]]
    then
        ADMIN=1
    else
        ADMIN=0
    fi
}

cache() {
    local u=$(([ -n "$USER" ] && echo "$USER" || echo "anonymous") | md5sum | cut -d' ' -f 1)
    if [ $CACHE -eq 1 -a "$RMETH" = "GET" ]
    then
        for r in "${!GURLS[@]}"
        do
            [[  -n "$r" && "$RURL" =~ $r && -f "$CACHEDIR/${GURLS[$r]}-$u.cache" ]] && answer 31337 "$(cat "$CACHEDIR/${GURLS[$r]}-$u.cache")"
        done
    else
        NOCACHE=1
        clearUserCache "$u"
    fi
}

cleanup() {
    local EP=$(date +%s)
    if [ $(($EP%30)) -eq 0 ]
    then
        debug "DELETED FILES!"
        find "$RWDIR" -type f -mmin +15 -exec rm -rf {} \;
    fi
}

declare -a MIDDLEWARES=(
    is_authenticated
    get_request_user
    is_admin
    cache
    cleanup
)