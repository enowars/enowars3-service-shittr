#!/bin/bash

RWDIR="../rw"
DBDIR="$RWDIR/db"
SESSIONSDIR="$DBDIR/sessions"
USERSDIR="$DBDIR/users"
SHITSDIR="$DBDIR/shitposts"
FOLLOWERSDIR="$DBDIR/followers"
HASHTAGSDIR="$DBDIR/hashtags"
MESSAGESDIR="$DBDIR/messages"
IMAGESDIR="$DBDIR/images"
LIKESDIR="$DBDIR/likes"

STATICDIR="./static"
TEMPLATESDIR="./templates"
CACHEDIR="$RWDIR/cache"

ENCKEY="$STATICDIR/enc.key"
LOGDIR="$RWDIR/logs"
LOGPATH="$LOGDIR/shittr.log"

mkdir -p "$SESSIONSDIR" "$USERSDIR" "$STATICDIR" "$TEMPLATESDIR" "$SHITSDIR" "$FOLLOWERSDIR" "$HASHTAGSDIR"
mkdir -p "$LOGDIR" "$MESSAGESDIR" "$CACHEDIR" "$IMAGESDIR" "$LIKESDIR"

if [ ! -f "$ENCKEY" ]
then
    hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random > "$ENCKEY"
fi

DEBUG=1
CACHE=0 # TODO: Finish implementation