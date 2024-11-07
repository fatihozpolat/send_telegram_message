#!/bin/bash

CHAT_ID=""
BOT_TOKEN=""

send_message() {
    local message="$1"

    message=$(echo -n "$message" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-)

    local url="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

    curl -s -X POST "$url" -d "chat_id=$CHAT_ID" -d "text=$message - $(date +%H:%M:%S)" -d "parse_mode=HTML" > /dev/null

    if [ $? -eq 0 ]; then
        echo "Mesaj başarıyla gönderildi!"
    else
        echo "Mesaj gönderilirken bir hata oluştu!"
    fi
}

if [ $# -eq 0 ]; then
    echo "Kullanım: $0 'mesajınız'"
    exit 1
fi

send_message "$1"
