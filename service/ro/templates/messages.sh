#!/bin/bash

cat <<EOF
    <div>
        <ul>
EOF
    getMsgs | while read mm
    do
        local IFS=':'
        read -r t m <<< "$mm"
        m=$(base64 -d <<< "$m")
        echo "<li class='$t'>$m</li>"
    done
cat <<EOF
        </ul>
    </div>
EOF