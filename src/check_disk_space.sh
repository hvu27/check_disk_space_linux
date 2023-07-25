#!/bin/bash

# Lấy thời gian hiện tại và giờ trong định dạng 24h
current_hour=$(date "+%H")

# Chạy lệnh df -h và lưu đầu ra vào biến disk_info
disk_info=$(df -h | grep "/root/xxxx/backup")
# Get %Use
usage_percentage=$(echo "$disk_info" | awk '{print $5}' | tr -d '%')

# Sử dụng awk để lấy các giá trị và định dạng thành bảng
table=$(echo "$disk_info" | awk 'BEGIN { printf "+----------------------------------+-------+------+-----------------------+\n"; printf "| Filesystem                       | Avail | Use% | Mounted               |\n"; printf "+==================================+=======+======+=======================+\n"; }
$NF=="/root/xxxx/xxx" { printf "| %-32s | %-5s | %-4s | %-21s |\n", $1, $4, $5, $NF; }
END { printf "+----------------------------------+-------+------+-----------------------+\n"; }')

# Kiểm tra nếu phần trăm sử dụng lớn hơn 95%
if [ "$usage_percentage" -gt 50 ]; then
    # Thay thế "<YOUR_BOT_TOKEN>" và "<YOUR_CHAT_ID>" bằng thông tin của bot và chat Telegram của bạn
    bot_token="5730563947:AAGCUmNjCD3FZdeUXVAmM0xmaMoaJbDEBbk"
    chat_id="-1001911775399"
    message_thread_id="701"
    message=""
    if [ "$current_hour" -eq 11 ]; then
        message="Trước backup XXXX lúc 11h30:\n"
    elif [ "$current_hour" -eq 13 ]; then
        message="Sau backup XXXX lúc 13h:\n"
    elif [ "$current_hour" -eq 23 ];  then
        message="Trước backup XXXX lúc 23h30:\n"
    elif [ "$current_hour" -eq 1 ]; then
        message="Sau backup XXXX lúc 1h:\n"
    fi
    # Gửi tin nhắn thông qua API của Telegram
    curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"$chat_id\",\"text\":\"<strong>$message</strong><pre>$table</pre>\",\"message_thread_id\":\"$message_thread_id\",\"parse_mode\":\"html\"}"
fi

#echo "$table"
