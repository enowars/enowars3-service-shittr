#!/bin/bash
h_static() {
    if [ -f "./$RURL" -o -d "./$RURL" ]
    then
        answer 1337 ""
    fi

    error
}