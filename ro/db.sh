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
    local b=$(echo "$2" | base64)
    sed -i -e "s/Bio=.*$/Bio=$b/g" "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user"
}

get_bio() {
    urldecode $(grep -P 'Bio=' "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | sed -e 's/Bio=//g' | base64 -d || "")
}

follow_shittr() {
    local fd="$FOLLOWERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1)"
    debug "$fd, $1, $2"
    mkdir -p "$fd"
    touch "$fd/$(echo $2 | md5sum | cut -d ' ' -f 1).follower"
}

unfollow_shittr() {
    find "$FOLLOWERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1)" -type f -name "$(echo $2 | md5sum | cut -d ' ' -f 1).follower" -delete
}

is_following() {
    find "$FOLLOWERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1)" -type f -name "$(echo $2 | md5sum | cut -d ' ' -f 1).follower" 2>/dev/null | wc -l
 }

follow_cnt() {
    ls -1 "$FOLLOWERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1)/" 2>/dev/null | wc -l 
}

follower_cnt() {
    find "$FOLLOWERSDIR/" -type f -name "$(echo $1 | md5sum | cut -d ' ' -f 1).follower" 2>/dev/null | wc -l
}

create_shit() {
    local s=$(echo "$2" | base64 | enc | base64 -w 0)
    local u=$(echo "$1" | md5sum | cut -d ' ' -f 1)
    local i=$(echo "$s:$u" | sha256sum | cut -d' ' -f 1)
    mkdir -p "$SHITSDIR/$u/"
    echo "$s" > "$SHITSDIR/$u/$i.shit"
    echo "$i" >> "$SHITSDIR/$u/diarrhea.log"
    echo "$u:$i.shit" >> "$SHITSDIR/diarrhea.log"


    echo $(urldecode "$2") |grep -oP '(#[A-Za-z0-9]+)' | while read h
    do
        debug "TAGTAGTAGTAG $h / $u & $i"
        create_tag "$h" "$u:$i"
    done
}

create_tag() {
    local h=$(echo "$1" | md5sum | cut -d' ' -f 1)
    echo "$2">>"$HASHTAGSDIR/$h.tag"
}

fluid_diarrhea() {
    declare -a ids=();
    declare -a -g SHITS=();
    while read l;
    do
        local ll=$(basename "$l" | sed -e 's/\.follower//g')
        ids+=("$ll")
    done < <(find "$FOLLOWERSDIR/$(echo "$1" | md5sum | cut -d' ' -f 1)/" -type f -name '*.follower'  2>/dev/null)

    local ids=$(join_by '|' "${ids[@]}")
    debug "IDS are ($ids)"

    while read l;
    do 
        local IFS=':'
        read -r uid sid <<< "$l"
        local s=$(cat "$SHITSDIR/$uid/$sid" | head -n 1 | base64 -d | dec | base64 -d)
        s=$(urldecode "$s")
        s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
        s=$(echo "$s" | sed  's|#\([A-Za-z0-9]*\)|<a href="/tag/\1">#\1</a>|g')
        local u=$(sed -n '2p' "$USERSDIR/$uid.user")
        SHITS+=("<a href='/@$u'>@$u</a>: $s")
    done < <(tac "$SHITSDIR/diarrhea.log" | grep -P "($ids)"  2>/dev/null | head -n "$2")
}

get_tag() {
    declare -a -g SHITS=();

    while read l;
    do 
        local IFS=':'
        read -r uid sid <<< "$l"
        local s=$(cat "$SHITSDIR/$uid/$sid.shit" | head -n 1 | base64 -d | dec | base64 -d)
        s=$(urldecode "$s")
        s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
        s=$(echo "$s" | sed  's|#\([A-Za-z0-9]*\)|<a href="/tag/\1">#\1</a>|g')
        local u=$(sed -n '2p' "$USERSDIR/$uid.user")
        SHITS+=("<a href='/@$u'>@$u</a>: $s")
    done < <(tac "$HASHTAGSDIR/$(echo "#$1" | md5sum | cut -d' ' -f 1).tag"  2>/dev/null | head -n "$2")
}


last_shits() {
    tail -n "$2" "$SHITSDIR/$(echo "$1" | md5sum | cut -d ' ' -f 1)/diarrhea.log"  2>/dev/null | tac
}

get_followers() {
    declare -a -g FOLLOWERS=();
    while read l
    do
        local ll=$([[ "$l" =~ ([^/]+)/[^/]+$ ]] && echo "${BASH_REMATCH[1]}")
        local u=$(sed -n '2p' "$USERSDIR/$ll.user")
        if [ -z "$u" -o "$(get_visibility $u)" = "off" ]
        then
            continue
        fi
        FOLLOWERS+=("$u")
    done < <(find "$FOLLOWERSDIR/" -type f -name "$(echo "$1" | md5sum | cut -d' ' -f 1).follower")
}

get_following() {
    declare -a -g FOLLOWING=();
    while read l
    do
        local ll=$(basename "$l" | sed -e 's/\.follower/\.user/g')
        local u=$(sed -n '2p' "$USERSDIR/$ll")
        if [ -z "$u" -o "$(get_visibility $u)" = "off" ]
        then
            continue
        fi
        FOLLOWING+=("$u")
    done < <(find "$FOLLOWERSDIR/$(echo "$1" | md5sum | cut -d' ' -f 1)/" -type f -name '*.follower' 2>/dev/null)
}