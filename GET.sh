#!/bin/bash
source db.sh

g_index() {
    answer 200 "$(addTplParam 'TITLE' 'Welcome | Bash0r';
    includeTpl 'header.tpl';
    includeTpl 'navigation.tpl';
    includeTpl 'footer.tpl';
    render 'index.tpl')"
}

g_lol() {
    redirect "/"
    exit 0
}

g_register() {
    answer 200 "$(addTplParam 'TITLE' 'Register | Bash0r';
    includeTpl 'header.tpl';
    includeTpl 'navigation.tpl';
    includeTpl 'footer.tpl';
    render 'register.tpl')";
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