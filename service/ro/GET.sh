#!/bin/bash
source db.sh

g_index() {
    if [ $AUTHENTICATED -eq 1 ]; then
        redirect "/home"
    fi
    answer 1337 "$(addTplParam 'TITLE' 'Welcome'; render 'index.sh')"
}

g_favicon() {
    cat ./static/imgs/favicon.ico
}

g_register() {
    answer 1337 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')";
}

g_login() {
    answer 1337 "$(addTplParam 'TITLE' 'Login';
    render 'login.sh')";
}

g_logout() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    logout "$(get_cookie 'auth')"

    addMsg "success" "Successfully logged out!"

    redirect "/"
}

g_home() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")


    answer 1337 "$(addTplParam 'TITLE' 'Home'; addTplParam 'USERNAME' "$user"; render 'home.sh')";
}

g_shittrs() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login"
    fi

    declare -a SHITTRS=();
    while read l
    do
        local u=$(sed -n '2p' "$l")
        if [ -z "$u" -o "$(get_visibility $u)" = "off" ]
        then
            continue
        fi
        SHITTRS+=("$u")
    done < <(find "$USERSDIR" -type f -name '*.user')

    answer 1337 "$(addTplParam 'TITLE' 'Shittrs'; addTplParam 'USERNAME' "$USER"; render 'shittrs.sh')";
}

g_shittr() {
    if [ $AUTHENTICATED -lt 1 ]; then
        redirect "/login"
    fi
    local OUSER="${BASH_REMATCH[1]}"

    local bio=$(get_bio "$OUSER")
    local fc=$(follow_cnt "$OUSER")
    local fec=$(follower_cnt "$OUSER")
    local if=$(is_following "$USER" "$OUSER")
    local u=$(echo "$OUSER" | md5sum | cut -d ' ' -f 1)

    declare -a SHITS=()
    while read q
    do
        if [ ! -f "$SHITSDIR/$u/$q.shit" ]
        then 
            continue
        fi 
        local s=$(cat "$SHITSDIR/$u/$q.shit" | head -n 1)
        if grep -qoP 'Private=0' "$SHITSDIR/$u/$q.shit" || [[ "$USER" = "$OUSER" ]]; then
            s=$(echo "$s" | base64 -d | dec | base64 -d)
        fi
        s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
        s=$(echo "$s" | sed  's|#\([A-Za-z0-9]*\)|<a href="/tag/\1">#\1</a>|g')
        local uu=$(sed -n '2p' "$USERSDIR/$u.user")
        SHITS+=("<div class='shit'><a href='/@$uu' class='user'>@$uu</a><div class='content'>$s</div><div class='links'><a href='/$u$q.shit' class='viewlink'>View</a> $(like_url "$u$q")</div></div>")
    done < <(last_shits "$OUSER" 25)

    answer 1337 "$(addTplParam 'TITLE' "@$OUSER's Profile"; addTplParam "if" "$if"; addTplParam "followCnt" "$fc"; addTplParam "followerCnt" "$fec"; addTplParam "bio" "$bio"; addTplParam 'OUSER' "$OUSER"; addTplParam 'USERNAME' "$USER"; render 'shittr.sh')";
}

g_follow_shittr() {
    if [ ! $AUTHENTICATED -gt 0 ]; then
        redirect "/login"
    fi
    local OUSER="${BASH_REMATCH[1]}"

    if [ $(followCnt "$USER") -gt 25 ]
    then
        error "This is a demo. Too many followers!"
    fi

    follow_shittr "$USER" "$OUSER"
    addMsg "success" "You're following @$OUSER now!"

    clearPageCache "g_shittr"
    clearPageCache "g_shittr_following"
    clearPageCache "g_shittr_followers"
    redirect "/@${OUSER}"
}

g_unfollow_shittr() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local OUSER="${BASH_REMATCH[1]}"

    unfollow_shittr "$user" "$OUSER"

    addMsg "success" "You're not following @$OUSER anymore!"

    clearPageCache "g_shittr"
    clearPageCache "g_shittr_following"
    clearPageCache "g_shittr_followers"
    redirect "/@${OUSER}"
}

g_settings() {
    NOCACHE=1
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local p=$(get_visibility "$user")
    local b=$(get_bio "$USER")

    answer 1337 "$(addTplParam 'TITLE' "Settings"; 
                    addTplParam 'isp' "$p"; 
                    addTplParam 'bio' "$b";
                    addTplParam 'USERNAME' "$USER"; 
                    render 'settings.sh')";
}

g_cashit() {
    local u="$(echo "$USER" | md5sum | cut -d' ' -f 1)"
    clearUserCache "$u"

    redirect "/"
}

g_tag(){
    NOCACHE=1
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local tag="${BASH_REMATCH[1]}"

    get_tag "$tag" "25"

    answer 1337 "$(addTplParam 'TITLE' "Tag ${tag}"; addTplParam "TAG" "$tag"; addTplParam 'USERNAME' "$USER"; render 'tag.sh')";
}

g_static() {
    addOutHdr "Expires" "$(date -d "$(date +"%a, %d %b %Y %H:%M:%S %Z") +5 min" +"%a, %d %b %Y %H:%M:%S %Z")"
    addOutHdr "Cache-Control" "max-age=300"
    if [[ "$RURL" =~ ".." ]]
    then
        error
    fi
    if [ -f "./$RURL" ]
    then
        answer 200 "$(cat "./$RURL")"
    elif [ -d "./$RURL" ]
    then
        answer 200 "$(ls -lha "./$RURL")"
    else
        answer 404 "GTFO"
    fi
}

g_diarrhea() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login"
    fi

    fluid_diarrhea "$USER" "25"

    answer 1337 "$(addTplParam 'TITLE' "Diarrhea";  addTplParam 'USERNAME' "$USER"; render 'diarrhea.sh')";
}

g_shit() {
    NOCACHE=1
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    answer 1337 "$(addTplParam 'TITLE' "Shit!"; addTplParam 'USERNAME' "$user"; render 'shit.sh')";
}

g_shittr_following() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local OUSER="${BASH_REMATCH[1]}"

    get_following "$OUSER"

    answer 1337 "$(addTplParam 'TITLE' "Whom is @$OUSER following"; addTplParam 'USERNAME' "$USER"; render 'following.sh')";
}

g_log() {
    NOCACHE=1
    if [ "$ADMIN" -eq 1 ]
    then
        answer 1337 "$(tac "$LOGPATH" | grep "$SOCAT_PEERADDR" | head -n 100)"
    fi

    error
}

g_shittr_followers() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local OUSER="${BASH_REMATCH[1]}"
    local user="$USER"

    get_followers "$OUSER"

    answer 1337 "$(addTplParam 'TITLE' "@$OUSER's Followers"; addTplParam 'USERNAME' "$user"; render 'followers.sh')";
}

g_images() {
    find "$IMAGESDIR" -type f -name "${BASH_REMATCH[1]}.png" 2> /dev/null | egrep '.*' > /dev/null || error 
    echo -e "HTTP/1.0 200 OK\nContent-Type: image/png\n"; 
    cat "$IMAGESDIR/${BASH_REMATCH[1]}.png" 
    
}

g_vshit() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local us="${BASH_REMATCH[1]}"
    local ui="${us:0:32}"
    local si="${us:32:96}"

    local s=$(cat "$SHITSDIR/$ui/$si.shit" | head -n 1)
    if grep -qoP 'Private=0' "$SHITSDIR/$ui/$si.shit"; then
        s=$(echo "$s" | base64 -d | dec | base64 -d)
    fi
    s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
    s=$(echo "$s" | sed  's|#\([A-Za-z0-9]*\)|<a href="/tag/\1">#\1</a>|g')
    local u=$(sed -n '2p' "$USERSDIR/$ui.user")
    SHIT="<div class='shit'><a href='/@$u' class='user'>@$u</a><div class='content'>$s</div><div class='links'>$(like_url "$ui" "$si")</div></div>"

    answer 1337 "$(addTplParam 'TITLE' "Shit";  addTplParam 'USERNAME' "$USER"; render 'vshit.sh')";
}

g_like_shit() {
    if [ ! $AUTHENTICATED -gt 0 ]; then
        redirect "/login"
    fi

    like_shit "${BASH_REMATCH[1]}"

    clearPageCache "g_vshit"
    redirect "/${BASH_REMATCH[1]}.shit"
}