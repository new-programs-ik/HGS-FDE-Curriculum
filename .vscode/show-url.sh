#!/bin/bash
# The 🌐 browser steps (week 01 console pages, 02 pricing calculator) in "Run all": check the page and print its link
# instead of opening a browser tab. Ctrl+click the link in the terminal to open it.
# usage: bash .vscode/show-url.sh <url>
url=$1
code=$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$url")
echo "$url  ->  HTTP $code"
echo "(not opened in the browser; Ctrl+click the link above to open it)"
case "$code" in 2??|3??) exit 0 ;; *) echo "!! page did not load"; exit 1 ;; esac
