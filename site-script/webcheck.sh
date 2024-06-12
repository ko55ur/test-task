#!/bin/bash
# Прерываем если где-то ошибка
set -e

trap "exit 1" TERM
export TOP_PID=$$
STDOUTFILE=".tempCurlStdOut" # временный файл для хранения вывода 
> $STDOUTFILE # очистка файла вывода

# чтение передаваемых аргументов
for i in "$@"; do
  case $i in
# передаем имя сайта 
    http*)
      WEBSITE="${i#*=}"
      shift
      ;;
# опция для поиска фразы или слова 
    -r=*|--findContent=*)
      FINDCONTENT="${i#*=}"
      shift
      ;;
    *)
      >&2 echo "Неизвестная опция: $i" # stderr
      exit 1
      ;;
  esac
done

if [[ -z "$WEBSITE" ]]; then
    >&2 echo "Не задан запрашиваемый URL" # stderr
    exit 1;
fi

function stdOutput { 
    if ! [[ "$SILENT" = true ]]; then
        echo "$1"
    fi
}

function stdError { 
    if ! test "$SILENT" = true; then
        >&2 echo "$1" # stderr
    fi
    kill -s TERM $TOP_PID # завершаем скрипт
}
# Проверяем соединение с интернетом переда запросом к сайту
if ping -q -w 1 -c 1 8.8.8.8 > /dev/null 2>&1; then
    stdOutput "Соединение с интеренетом OK"
    HTTPCODE=$(curl --max-time 5 --silent --write-out %{response_code} --output "$STDOUTFILE" "$WEBSITE")
# Если получили код 200 или 302, то уже ищем нужный нам контент
    if [[ "$HTTPCODE" -eq 200 ]] || [[ "$HTTPCODE" -eq 302 ]]; then
        stdOutput "HTTP STATUS CODE $HTTPCODE -> OK"
	    wget -q "$WEBSITE" -O - | grep -qi "$FINDCONTENT" && echo "Страница содержит искомый текст" || echo "Страница не содержит искомый текст"
    else
        stdError "Запрос завершился со статусом ошибки CODE $HTTPCODE?"
    fi
else
    >&2 echo "Internet connectivity not available" #stderr
    exit 1
fi
