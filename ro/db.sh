#!/bin/bash

create_user() {
    local pw=$(echo "$2" | sha256sum | cut -d' ' -f 1)
    local id=$(echo "$1" | md5sum | cut -d ' ' -f 1)

    debug "$pw, $id"
    echo "$pw" > "$USERSDIR/$id.user"
    echo "$1" >> "$USERSDIR/$id.user"
    echo "Public=on" >> "$USERSDIR/$id.user"
    echo "Bio=SGVsbG8sIEknbSBhIHNoaXR0ciE=" >> "$USERSDIR/$id.user"
    return 0
}

user_exists() {
    [ -f "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" ]
}

valid_login() {
    local dbpw=$(cat "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | head -n 1)
    local sendpw=$(echo "$2" | sha256sum | cut -d' ' -f 1)

    [ "$dbpw" = "$sendpw" ]
}

generate_session() {
    local rand=$(dd if=/dev/urandom bs=1 count=3 | base64 2>/dev/null)
    echo $(echo $1 | md5sum | cut -d ' ' -f 1) > "$SESSIONSDIR/$rand.session"
    echo "$rand"
}

valid_session() {
    [ -f "$SESSIONSDIR/$1.session" ]
}

logout() {
    rm "$SESSIONSDIR/$1.session" || true
}

get_user() {
    local id=$(cat "$SESSIONSDIR/$1.session")
    sed -n '2p' "$USERSDIR/$id.user"
}

set_visibility() {
    if [ "off" = "$2" -o -z "$2" ]
    then
        s="on"
        p="off"
    else
        s="off"
        p="on"
    fi
    debug "$s => $p"
    sed -i -e "s/Public=$s/Public=$p/g" "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user"
}

get_visibility() {
    grep -P 'Public=' "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | sed -e 's/Public=//g' || "on"
}

set_bio() {
    debug "$2"
    local b=$(echo "$2" | base64)
    sed -i -e "s/Bio=.*$/Bio=$b/g" "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user"
}

get_bio() {
    urldecode $(grep -P 'Bio=' "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | sed -e 's/Bio=//g' | base64 -d || "")
}
