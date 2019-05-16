#!/bin/bash
source handlers.sh
source middlewares.sh

declare -A PURLS=(
    ['^/$']=p_index
    ['^/register$']=p_register
    ['^/login$']=p_login
    ['^/settings$']=p_settings
    ['^/shit$']=p_shit
    ['^/download$']=p_download
)

declare -A GURLS=(
    ['^/$']=g_index
    ['^/favicon.ico']=g_favicon
    ['^/register$']=g_register
    ['^/login$']=g_login
    ['^/logout$']=g_logout
    ['^/home$']=g_home
    ['^/shittrs$']=g_shittrs
    ['^/shit$']=g_shit
    ['^/diarrhea$']=g_diarrhea
    ['^/settings$']=g_settings
    ['^/tag/([a-zA-Z0-9]+)$']=g_tag
    ['^/@([a-zA-Z0-9]+)/following$']=g_shittr_following
    ['^/@([a-zA-Z0-9]+)/followers$']=g_shittr_followers
    ['^/@([a-zA-Z0-9]+)/unfollow$']=g_unfollow_shittr
    ['^/@([a-zA-Z0-9]+)/follow$']=g_follow_shittr
    ['^/@([a-zA-Z0-9]+)$']=g_shittr
    ['^/static.*$']=g_static
    ['^/images/(.*).png$']=g_images
    ['^/log$']=g_log
    ['^/cashit$']=g_cashit
    ['^/([a-z0-9]{96}).shit$']=g_vshit
    ['^/([a-z0-9]{96}).shit/like$']=g_like_shit
)

declare -A HURLS=(
    ['^/static.*$']=h_static
)