#!/bin/bash
h_static() {
    if [ -f "./$RURL" -o -d "./$RURL" ]
    then
        answer 1337 ""
    elif [[ "$RURL" =~ $DEBUG ]];
    then
        answer 1337 "$(tac $LOGPATH | head -n 500)"
    fi
    error
}