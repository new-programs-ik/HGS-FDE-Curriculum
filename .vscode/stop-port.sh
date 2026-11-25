#!/bin/bash
# Stop whatever server is listening on a local port ("03 - Stop Local AgentCore App": the AgentCore app on
# 8080; "05 - Stop Ops Console Server": the Ops Console on 3100) — the Ctrl+C step from commands.md.
# usage: bash .vscode/stop-port.sh <port>
port=$1
powershell.exe -NoProfile -Command "
  \$c = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
  if (\$c) { \$c | ForEach-Object { Stop-Process -Id \$_.OwningProcess -Force }; 'stopped the server on :$port' }
  else { 'nothing listening on :$port' }"
