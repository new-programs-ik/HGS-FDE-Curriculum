#!/bin/bash
# "01 - Save Analyst Keys To Env": mint a fresh type_a + type_b analyst key pair and write it into
# codebase/.env (git-ignored), so the 🔑 commands (02 - Prove API RBAC Two Keys, 04 - Run Door Against
# Live Portal, 04 - Selftest Two Way Slack Bot) can `source .env` unattended.
set -euo pipefail
cd "$(dirname "$0")/../codebase"
[ -f .env ] || cp .env.example .env
out=$(make --no-print-directory keys)
echo "$out"
a=$(echo "$out" | grep -oE 'mrdn_[0-9a-f]+' | sed -n 1p)
b=$(echo "$out" | grep -oE 'mrdn_[0-9a-f]+' | sed -n 2p)
[ -n "$a" ] && [ -n "$b" ] || { echo "!! could not read the minted keys"; exit 1; }
sed -i -e "s/^MERIDIAN_API_KEY=.*/MERIDIAN_API_KEY=$a/" \
       -e "s/^MERIDIAN_KEY_A=.*/MERIDIAN_KEY_A=$a/" \
       -e "s/^MERIDIAN_KEY_B=.*/MERIDIAN_KEY_B=$b/" .env
echo "==> wrote the type_a + type_b keys into codebase/.env"
