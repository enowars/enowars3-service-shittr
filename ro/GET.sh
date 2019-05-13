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


    answer 200 "$(addTplParam 'TITLE' "@$OUSER's Profile"; addTplParam 'OUSER' "$OUSER"; addTplParam 'USERNAME' "$user"; render 'shittr.sh')";
}

g_settings() {
    if [ ! $AUTHENTICATED -eq 1 ]; then
        redirect "/login"
    fi
    local user=$(get_user "$(get_cookie 'auth')")
    local p=$(get_visibility "$user")
    local b=$(get_bio "$user")

    answer 1337 "$(addTplParam 'TITLE' "My Profile"; 
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