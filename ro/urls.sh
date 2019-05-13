#!/bin/bash
source handlers.sh
source middlewares.sh

declare -a MIDDLEWARES=(
    is_authenticated
)

declare -A PURLS=(
    ['^/$']=p_index
    ['^/register$']=p_register
    ['^/login$']=p_login
    ['^/settings$']=p_settings
)

declare -A GURLS=(
    ['^/$']=g_index
    ['^/favicon.ico']=g_favicon
    ['^/register$']=g_register
    ['^/login$']=g_login
    ['^/logout$']=g_logout
    ['^/home$']=g_home
    ['^/shittrs$']=g_shittrs
    ['^/settings$']=g_settings
    ['^/@([a-zA-Z0-9]+)$']=g_shittr
    ['^/static.*$']=g_static
)