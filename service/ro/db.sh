#!/bin/bash

create_user() {
    local pw=$(echo "$2" | sha256sum | cut -d' ' -f 1)
    local id=$(echo "$1" | md5sum | cut -d ' ' -f 1)

    debug "$pw, $id"
    echo "$pw" > "$USERSDIR/$id.user"
    echo "$1" >> "$USERSDIR/$id.user"
    echo "Public=on" >> "$USERSDIR/$id.user"
    echo "Bio=SGVsbG8sIEknbSB1c2luZyBzaGl0dHIhCg==" >> "$USERSDIR/$id.user"
    echo "Admin=0" >> "$USERSDIR/$id.user"
    follow_shittr "$1" "$1"
    return 0
}

user_exists() {
    [ -f "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" ]
}

packShit() {
    local up="$SHITSDIR/$(echo "$USER" | md5sum | cut -d ' ' -f 1)"
    cd "$up" && tar cf - *
}

valid_login() {
    local dbpw=$(cat "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | head -n 1)
    local sendpw=$(echo "$2" | sha256sum | cut -d' ' -f 1)

    if grep -qoP "Admin=1" "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user"; then 
        ADMIN=1
    fi

    [ "$dbpw" = "$sendpw" ]
}

generate_session() {
    local rand=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | xxd |  tr -dc '[:digit:]\n\r' | rev | head -n1)
    local sessid=$(echo "${rand:0:3}" | md5sum | cut -d ' ' -f 1)
    echo $(echo "$1" | md5sum | cut -d ' ' -f 1) > "$SESSIONSDIR/$sessid.session"
    debug "Session is $rand"
    echo "${sessid}"
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

addMsg() {
    local b=$(echo "$2" | base64 -w 0)
    echo "$1:$b">> "$MESSAGESDIR/$(echo $USER | md5sum | cut -d ' ' -f 1).msg"
}

getMsgs() {
    tac "$MESSAGESDIR/$(echo  $USER | md5sum | cut -d ' ' -f 1).msg"
    rm  "$MESSAGESDIR/$(echo $USER | md5sum | cut -d ' ' -f 1).msg"
}

get_visibility() {
    if [ "$ADMIN" -eq 1 ]
    then
        "off"
        return
    fi
    grep -P 'Public=' "$USERSDIR/$(echo $1 | md5sum | cut -d ' ' -f 1).user" | sed -e 's/Public=//g' || "on"
}

set_bio() {
    local b=$(echo "$2" | base64 -w 0)
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
    local s="$2"
    [[ "$3" =~ on ]] && local pv="1" || local pv="0"
    local e=0
    while read l
    do
        [[ ! "$l" =~ .png ]] && continue
        local f="$(echo "$l" | rev | cut -d / -f 1 | rev )"
        local p=$(urldecode "$IMAGESDIR/$f")
        curl --silent -k "$l" -o "$p"
        s=$(echo $(urldecode "$s") | sed -e 's|'"$l"'|XXXIMGXXX|g')
        s=$(htmlEscape "$s")
        s=$(echo "$s" | sed -e 's|XXXIMGXXX|<img src="/images/'"$f"'">|g')
        s=$(urlencode "$s")
        e=1
    done < <(echo $(urldecode "$s") |grep -oP '(http.?)?://[\S\[\]:.png]+' | head -n 1)
    s=$(urldecode "$s")
    if [ $e -eq 0 ]; then 
        s=$(htmlEscape "$s")
    fi
    local s=$(echo "$s" | base64 -w 0 | enc | base64 -w 0)
    local u=$(echo "$1" | md5sum | cut -d ' ' -f 1)
    local i=$(echo "$s:$u:$(date +%s)" | sha256sum | cut -d' ' -f 1)
    mkdir -p "$SHITSDIR/$u/"
    echo "$s" > "$SHITSDIR/$u/$i.shit"
    declare -g RET=$(cat "$SHITSDIR/$u/$i.shit")
    echo "Private=$pv" >> "$SHITSDIR/$u/$i.shit"
    echo "$i" >> "$SHITSDIR/$u/diarrhea.log"
    echo "$u:$i" >> "$SHITSDIR/diarrhea.log"


    echo $(urldecode "$2") |grep -oP '(#[A-Za-z0-9]+)' | while read h
    do
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
    local myid=$(echo $USER | md5sum | cut -d ' ' -f 1)
    while read l;
    do
        local ll=$(basename "$l" | sed -e 's/\.follower//g')
        if grep -q 'Public=off' "$USERSDIR/$ll.user";
        then
            continue
        fi
        ids+=("$ll")
    done < <(find "$FOLLOWERSDIR/$(echo "$1" | md5sum | cut -d' ' -f 1)/" -type f -name '*.follower'  2>/dev/null)

    debug "FOLLOWER IDS are ${ids[@]}"
    [ "$ADMIN" -gt 0 ] && local ids='[a-z0-9]{64}' || local ids=$(join_by '|' "${ids[@]}")

    while read l;
    do 
        local IFS=':'
        read -r uid sid <<< "$l"
        if [ ! -f "$SHITSDIR/$uid/$sid.shit" ]
        then 
            continue
        fi 
        local s=$(cat "$SHITSDIR/$uid/$sid.shit" | head -n 1)
        if grep -qoP 'Private=0' "$SHITSDIR/$uid/$sid.shit" || [[ "$uid" = "$myid" ]]; then
            s=$(echo "$s" | base64 -d | dec | base64 -d)
        fi
        s=$(urldecode "$s")
        s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
        s=$(echo "$s" | sed  's|#\([A-Za-z0-9]*\)|<a href="/tag/\1">#\1</a>|g')
        local u=$(sed -n '2p' "$USERSDIR/$uid.user")
        SHITS+=("<div class='shit'><a href='/@$u' class='user'>@$u</a><div class='content'>$s</div><div class='links'><a href='/$uid$sid.shit' class='viewlink'>View</a> $(like_url "$uid$sid")</div></div>")
    done < <(tac "$SHITSDIR/diarrhea.log" | grep -P "($ids)|($myid)"  2>/dev/null | head -n "$2")
}

get_tag() {
    declare -a -g SHITS=();

    while read l;
    do 
        local IFS=':'
        read -r uid sid <<< "$l"
        if [ ! -f "$SHITSDIR/$uid/$sid.shit" ]
        then 
            continue
        fi 
        local s=$(cat "$SHITSDIR/$uid/$sid.shit" | head -n 1)
        if grep -qoP 'Private=0' "$SHITSDIR/$uid/$sid.shit"; then
            s=$(echo "$s" | base64 -d | dec | base64 -d)
        fi
        s=$(urldecode "$s")
        s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
        s=$(echo "$s" | sed  's|#\([A-Za-z0-9]*\)|<a href="/tag/\1">#\1</a>|g')
        local u=$(sed -n '2p' "$USERSDIR/$uid.user")
        SHITS+=("<div class='shit'><a href='/@$u' class='user'>@$u</a><div class='content'>$s</div><div class='links'><a href='/$uid$sid.shit' class='viewlink'>View</a> $(like_url "$uid$sid")</div></div>")
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
        if [ -z "$u" ]
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

like_shit() {
    local ui="${1:0:32}"
    local si="${1:32:96}"

    mkdir -p "$LIKESDIR/$ui/$si"
    touch "$LIKESDIR/$ui/$si/$(echo "$USER" | md5sum | cut -d ' ' -f 1).like"
}

like_cnt() {
    find "$LIKESDIR/${1:0:32}/${1:32:96}" -type f -name "$(echo "$USER" | md5sum | cut -d ' ' -f 1).like" 2>/dev/null | wc -l
}

like_url() {
    echo "<a href='/$1$2.shit/like' class='likecnt'>$(like_cnt "$1$2") Like(s)</a>"
}