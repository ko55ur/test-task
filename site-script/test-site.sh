#!/usr/bin/env bash
set -e

url="https://nxt.selesvsev.ru"

search_phrase="nextcloud"

# Запрашиваем статус сайта, на котором потом будем искать нужный текст
status="$(curl -s -w "%{http_code}" -m 5 $url)"
# Проверяем какие коды получили в ответ на запрос, если 200 или 302, то ищем уже текст. Если другая ошибка, то выводит ее код
if [[ "$status" -eq 200 ]] || [[ "$status" -eq 302 ]]; then
    wget -q "$url" -O - | grep -qi "$search_phrase" && echo "Страница содержит искомый текст" || echo "Страница не содержит искомый текст"

else
    echo "Request failed with code $status"
fi
