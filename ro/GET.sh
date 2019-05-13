#!/bin/bash
source db.sh

g_index() {
    if [ $AUTHENTICATED -eq 1 ]; then
        redirect "/home"
    fi
    answer 200 "$(addTplParam 'TITLE' 'Welcome'; render 'index.sh')"
}

g_favicon() {
    cat ./static/imgs/favicon.ico
}

g_register() {
    answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')";
}

g_login() {
    answer 200 "$(addTplParam 'TITLE' 'Login';
    render 'login.sh')";
}

g_logout() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    logout "$(get_cookie 'auth')"

    redirect "/"
}

g_home() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")


    answer 200 "$(addTplParam 'TITLE' 'Home'; addTplParam 'USERNAME' "$user"; render 'home.sh')";
}

g_shittrs() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")

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

    answer 200 "$(addTplParam 'TITLE' 'Shittrs'; addTplParam 'USERNAME' "$user"; render 'shittrs.sh')";
}

g_shittr() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local OUSER="${BASH_REMATCH[1]}"

    local bio=$(get_bio "$OUSER")
    local fc=$(follow_cnt "$OUSER")
    local fec=$(follower_cnt "$OUSER")
    local if=$(is_following "$user" "$OUSER")
    local u=$(echo "$OUSER" | md5sum | cut -d ' ' -f 1)

    declare -a SHITS=()
    while read q
    do
        local s=$(cat "./$SHITSDIR/$u/$q.shit" | head -n 1 | base64 -d)
        s=$(urldecode "$s")
        s=$(echo "$s" | sed  's|@\([A-Za-z0-9]*\)|<a href="/@\1">@\1</a>|g')
        SHITS+=("$s")
    done < <(last_shits "$OUSER" 25)

    answer 200 "$(addTplParam 'TITLE' "@$OUSER's Profile"; addTplParam "if" "$if"; addTplParam "followCnt" "$fc"; addTplParam "followerCnt" "$fec"; addTplParam "bio" "$bio"; addTplParam 'OUSER' "$OUSER"; addTplParam 'USERNAME' "$user"; render 'shittr.sh')";
}

g_follow_shittr() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local OUSER="${BASH_REMATCH[1]}"

    if [ $(followCnt "$user") -gt 25 ]
    then
        error "This is a demo. Too many followers!"
    fi

    follow_shittr "$user" "$OUSER"

    redirect "/@${OUSER}"
}

g_unfollow_shittr() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local OUSER="${BASH_REMATCH[1]}"

    unfollow_shittr "$user" "$OUSER"

    redirect "/@${OUSER}"
}

g_settings() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local p=$(get_visibility "$user")
    local b=$(get_bio "$user")

    answer 1337 "$(addTplParam 'TITLE' "Settings"; 
                    addTplParam 'isp' "$p"; 
                    addTplParam 'bio' "$b";
                    addTplParam 'USERNAME' "$user"; 
                    render 'settings.sh')";
}


g_static() {
    if [[ "$RURL" =~ ".." ]]
    then
        error
    fi
    if [ -f "./$RURL" ]
    then
        cat "./$RURL"
    elif [ -d "./$RURL" ]
    then
        ls -lha "./$RURL"
    else
        answer 404 "GTFO"
    fi
}

g_diarrhea() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")

    fluid_diarrhea "$user" "25"

    answer 1337 "$(addTplParam 'TITLE' "Diarrhea";  addTplParam 'USERNAME' "$user"; render 'diarrhea.sh')";
}

g_shit() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    answer 200 "$(addTplParam 'TITLE' "Shit!"; addTplParam 'USERNAME' "$user"; render 'shit.sh')";
}

g_shittr_following() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local OUSER="${BASH_REMATCH[1]}"

    get_following "$OUSER"

    answer 200 "$(addTplParam 'TITLE' "Whom is @$OUSER following"; addTplParam 'USERNAME' "$user"; render 'following.sh')";
}

g_shittr_followers() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local OUSER="${BASH_REMATCH[1]}"

    get_followers "$OUSER"

    answer 200 "$(addTplParam 'TITLE' "@$OUSER's Followers"; addTplParam 'USERNAME' "$user"; render 'followers.sh')";
}