#!/bin/bash

create_user() {
    local pw=$(echo "$2" | sha256sum | cut -d' ' -f 1)
    local id=$(echo "$1" | md5sum | cut -d ' ' -f 1)

    debug "$pw, $id"
    echo "$pw" > "./db/users/$id.user"
    echo "$1" >> "./db/users/$id.user"
    return 0
}

user_exists() {
    [ -f "./db/users/$(echo $1 | md5sum | cut -d ' ' -f 1).user" ]
}

valid_login() {
    local dbpw=$(cat "./db/users/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | head -n 1)
    local sendpw=$(echo "$2" | sha256sum | cut -d' ' -f 1)

    [ "$dbpw" = "$sendpw" ]
}

generate_session() {
    local rand=$(dd if=/dev/urandom bs=1 count=3 | base64)
    echo $(echo $1 | md5sum | cut -d ' ' -f 1) > "./db/sessions/$rand.session"
    echo "$rand"
}

valid_session() {
    [ -f "./db/sessions/$1.session" ]
}

logout() {
    rm "./db/sessions/$1.session" || true
}

get_user() {
    local id=$(cat "./db/sessions/$1.session")
    sed -n '2p' "./db/users/$id.user"
}