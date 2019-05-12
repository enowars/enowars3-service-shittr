#!/bin/bash
source db.sh

g_index() {
    addTplParam "TITLE" "Bash0r"
    includeTpl 'header.tpl'
    includeTpl 'navigation.tpl'
    includeTpl 'footer.tpl'
    render 'index.tpl'
}

g_static() {
    if [[ "$RURL" =~ ".." ]]
    then
        error
    fi
    if [ -f "./$RURL" ]
    then
        cat "./$RURL"
    fi 
}