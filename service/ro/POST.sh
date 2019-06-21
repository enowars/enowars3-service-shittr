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
    if [[ ! "$username" =~ ^[a-zA-Z0-9]+$ ]] || [[ ! "$password" =~ ^[a-zA-Z0-9]+$ ]]
    then
        error "username and password do not match regex"
    fi 
    if user_exists "$username"; then
        error "user already exists"
    fi

    if ! create_user "$username" "$password"; then
        error "could not create user"
    fi


    addMsg "success" "Successfully signed up as @$username!"

    redirect "/login"
}

p_login() {
    local username="${PARAMS[username]}"
    local password="${PARAMS[password]}"

    if [ -z "$username" -o -z "$password" ]
    then 
        error "no username or password"
    fi 
    if [[ ! "$username" =~ ^[a-zA-Z0-9]+$ ]] || [[ ! "$password" =~ ^[a-zA-Z0-9]+$ ]]
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

    addOutHdr "Set-Cookie" "auth=$cookie;max-age=300"

    addMsg "success" "Successfully logged in as @$username!"

    redirect "/home"
}

p_settings() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")

    set_visibility "$user" "${PARAMS[public]}"
    set_bio "$user" "${PARAMS[bio]}"

    addMsg "success" "Profile settings successfully updated!"

    redirect "/settings"
}

p_shit() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")

    if [ ${#PARAMS[post]} -gt 300 ]
    then
        error "Message too long"
    fi

    create_shit "$user" "${PARAMS[post]}" "${PARAMS[private]}"

    addMsg "success" "Successfully shat! Message: $RET"

    clearPageCache "g_diarrhea"

    redirect "/diarrhea"
}

p_download() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi

    echo -e "HTTP/1.0 200 OK\nContent-Type: application/octet-stream\nContent-Disposition: attachment; filename=shits.tar\n"; 

    packShit

}