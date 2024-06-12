#!/bin/bash
set -e
trap "exit 1" TERM
export TOP_PID=$$
STDOUTFILE=".tempCurlStdOut" # temp file to store stdout
> $STDOUTFILE # cleans the file content

# Argument parsing follows our specification
for i in "$@"; do
  case $i in
    http*)
      WEBSITE="${i#*=}"
      shift
      ;;
    -r=*|--findContent=*)
      FINDCONTENT="${i#*=}"
      shift
      ;;
    *)
      >&2 echo "Unknown option: $i" # stderr
      exit 1
      ;;
  esac
done

if [[ -z "$WEBSITE" ]]; then
    >&2 echo "Missing required URL" # stderr
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
    kill -s TERM $TOP_PID # abort the script execution
}

if ping -q -w 1 -c 1 8.8.8.8 > /dev/null 2>&1; then
    stdOutput "Internet connectivity OK"
    HTTPCODE=$(curl --max-time 5 --silent --write-out %{response_code} --output "$STDOUTFILE" "$WEBSITE")
    CONTENT=$(<$STDOUTFILE) # if there are no errors, this is the HTML code of the web page
    if [[ "$HTTPCODE" -eq 200 ]] || [[ "$HTTPCODE" -eq 302 ]]; then
        stdOutput "HTTP STATUS CODE $HTTPCODE -> OK"
    else
        stdError "HTTP STATUS CODE $HTTPCODE -> Has something gone wrong?"
    fi
    if ! [[ -z "$FINDCONTENT" ]]; then
        if ! echo "$CONTENT" | grep -iq "$FINDCONTENT"; then # case insensitive check
            stdError "Required content '$FINDCONTENT' is absent"
        fi
    fi
else
    >&2 echo "Internet connectivity not available" #stderr
    exit 1
fi