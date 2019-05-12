#!/bin/bash
source handlers.sh

declare -A PURLS=(
    ['^/$']=p_index
)

declare -A GURLS=(
    ['^/$']=g_index
    ['^/static/.*$']=g_static
)