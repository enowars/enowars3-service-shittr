#!/bin/bash
source db.sh

g_index() {
    answer 200 "$(addTplParam 'TITLE' 'Welcome | Bash0r';
    includeTpl 'header.tpl';
    includeTpl 'navigation.tpl';
    includeTpl 'footer.tpl';
    render 'index.tpl')"
}

g_favicon() {
    cat ./static/imgs/favicon.ico
}

g_register() {
    answer 200 "$(addTplParam 'TITLE' 'Register | Bash0r';
    includeTpl 'header.tpl';
    includeTpl 'navigation.tpl';
    includeTpl 'footer.tpl';
    render 'register.tpl')";
}

g_login() {
    answer 200 "$(addTplParam 'TITLE' 'Login | Bash0r';
    includeTpl 'header.tpl';
    includeTpl 'navigation.tpl';
    includeTpl 'footer.tpl';
    render 'login.tpl')";
}

g_logout() {
    if ! valid_session "$(get_cookie 'auth')"; then
        error "no valid session"
    fi
    logout "$(get_cookie 'auth')"

    redirect "/"
}

g_home() {
    if ! valid_session "$(get_cookie 'auth')"; then
        error "no valid session"
    fi
    local user=$(get_user "$(get_cookie 'auth')")


    answer 200 "$(addTplParam 'TITLE' 'Home | Bash0r';
    addTplParam 'USERNAME' "$user";
    includeTpl 'header.tpl';
    includeTpl 'navigation.tpl';
    includeTpl 'footer.tpl';
    render 'home.tpl')";
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
    fi 
}