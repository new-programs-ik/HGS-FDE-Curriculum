#!/bin/bash
# Start a long-running server DETACHED from this terminal, stream its output
# here until it answers, then exit 0, so "Run all" moves on without relying
# on VS Code's background-task tracking. The server keeps running;
# stop-port.sh ("03 - Stop Local AgentCore App", "05 - Stop Ops Console Server") stops it.
#
# usage (from the repo root):  bash .vscode/start-bg.sh console     # "01 - Serve Ops Console Locally": make web on :3100
#                              bash .vscode/start-bg.sh agentcore   # "03 - Serve AgentCore App Locally": app.py on :8080
set -u
case "${1:-}" in
  console)   url=http://localhost:3100/login
             cmd='cd codebase && make web' ;;
  agentcore) url=http://localhost:8080/ping
             cmd='cd codebase/labs/build/demo/deploy/agentcore && MERIDIAN_MOCK=1 python3 app.py' ;;
  *) echo "usage: bash .vscode/start-bg.sh console|agentcore"; exit 2 ;;
esac
name=$1; log="/tmp/ik-fde-$name.log"; script="/tmp/ik-fde-$name.sh"
if curl -s -o /dev/null -f "$url"; then   # already up (e.g. left running by the last run)
  echo "==> $name is already running: $url  (leaving it up)"; exit 0
fi
: > "$log"
printf '#!/bin/bash\ncd %q\n( %s ) > %q 2>&1\n' "$PWD" "$cmd" "$log" > "$script"

echo "\$ $cmd"
echo "   (started in the background; its output follows, and this terminal exits once $url answers)"
echo
powershell.exe -NoProfile -Command \
  "Start-Process -WindowStyle Hidden -FilePath 'C:\Program Files\Git\bin\bash.exe' -ArgumentList '$(cygpath -w "$script")'" >/dev/null

tail -n +1 -f "$log" & tp=$!
trap 'kill $tp 2>/dev/null' EXIT
for _ in $(seq 1 300); do
  if curl -s -o /dev/null -f "$url"; then
    sleep 1; echo; echo "==> $name is up: $url  (running in the background)"; exit 0
  fi
  if grep -qE 'make: \*\*\*|Traceback|EADDRINUSE' "$log"; then
    sleep 1; echo; echo "!! $name failed to start (full log: $log)"; exit 1
  fi
  sleep 1
done
echo; echo "!! $name did not answer on $url within 300 s (full log: $log)"; exit 1
