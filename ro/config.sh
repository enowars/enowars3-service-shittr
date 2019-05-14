#!/bin/bash

DBDIR="../rw/db"
SESSIONSDIR="$DBDIR/sessions"
USERSDIR="$DBDIR/users"
SHITSDIR="$DBDIR/shitposts"
FOLLOWERSDIR="$DBDIR/followers"
HASHTAGSDIR="$DBDIR/hashtags"

STATICDIR="./static"
TEMPLATESDIR="./templates"

ENCKEY="$STATICDIR/enc.key"

mkdir -p "$SESSIONSDIR" "$USERSDIR" "$STATICDIR" "$TEMPLATESDIR" "$SHITSDIR" "$FOLLOWERSDIR" "$HASHTAGSDIR"

if [ ! -f "$ENCKEY" ]
then
    hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random > "$ENCKEY"
fi
