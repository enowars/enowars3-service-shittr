#!/bin/bash
source handlers.sh

declare -A PURLS=(
    ['^/$']=p_index
    ['^/register$']=p_register
)

declare -A GURLS=(
    ['^/$']=g_index
    ['^/register$']=g_register
    ['^/lol$']=g_lol
    ['^/static.*$']=g_static
)