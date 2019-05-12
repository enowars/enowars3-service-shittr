#!/bin/bash

p_index() {
    redirect "/"
}

g_register() {
    addTplParam "TITLE" "Register | Bash0r"
    includeTpl 'header.tpl'
    includeTpl 'navigation.tpl'
    includeTpl 'footer.tpl'
    render 'register.tpl'
}