#!/bin/bash
source db.sh

p_index() {
    redirect "/"
}

p_register() {
    local username="${PARAMS[username]}"
    local password="${PARAMS[password]}"

    if [ -z "$username" -o -z "$password" ]
    then 
        error "no username or password"
    fi 
    if [[ ! "$username" =~ ^[A-Z0-9]$ ]] && [[ "$password" =~ ^[A-Z0-9]$ ]]
    then
        error "username and password do not match regex"
    fi 
    if user_exists "$username"; then
        error "user already exists"
    fi

    if ! create_user "$username" "$password"; then
        error "could not create user"
    fi

    redirect "/login"
}

p_login() {
    local username="${PARAMS[username]}"
    local password="${PARAMS[password]}"

    if [ -z "$username" -o -z "$password" ]
    then 
        error "no username or password"
    fi 
    if [[ ! "$username" =~ ^[A-Z0-9]$ ]] && [[ "$password" =~ ^[A-Z0-9]$ ]]
    then
        error "username and password do not match regex"
    fi 
    if ! user_exists "$username"; then
        error "user does not exist"
    fi
    if ! valid_login "$username" "$password"
    then
        error "wrong credentials"
    fi

    local cookie="$(generate_session $username)"

    addOutHdr "Set-Cookie" "auth=$cookie"

    redirect "/home"
}

p_login() {
    local username="${PARAMS[username]}"
    local password="${PARAMS[password]}"

    if [ -z "$username" -o -z "$password" ]
    then 
        error "no username or password"
    fi 
    if [[ ! "$username" =~ ^[A-Z0-9]$ ]] && [[ "$password" =~ ^[A-Z0-9]$ ]]
    then
        error "username and password do not match regex"
    fi 
    if ! user_exists "$username"; then
        error "user does not exist"
    fi
    if ! valid_login "$username" "$password"
    then
        error "wrong credentials"
    fi

    local cookie="$(generate_session $username)"

    addOutHdr "Set-Cookie" "auth=$cookie"

    redirect "/home"
}

p_settings() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")

    set_visibility "$user" "${PARAMS[public]}"
    set_bio "$user" "${PARAMS[bio]}"

    redirect "/settings"
}

p_shit() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")

    create_shit "$user" "${PARAMS[post]}"

    redirect "/diarrhea"
}