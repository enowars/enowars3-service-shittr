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

declare -a MIDDLEWARES=(
    is_authenticated
    get_request_user
    is_admin
)