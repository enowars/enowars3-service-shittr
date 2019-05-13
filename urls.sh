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
)

declare -A GURLS=(
    ['^/$']=g_index
    ['^/favicon.ico']=g_favicon
    ['^/register$']=g_register
    ['^/login$']=g_login
    ['^/logout$']=g_logout
    ['^/home$']=g_home
    ['^/static.*$']=g_static
)