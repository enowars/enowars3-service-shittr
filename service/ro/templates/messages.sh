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
        m=$(htmlEscape "$m")
        echo "<div class='alert alert-primary' role='alert'>$m</div>"
    done
cat <<EOF
        </ul>
    </div>
EOF