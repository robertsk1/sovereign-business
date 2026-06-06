#!/bin/bash
# Sovereign Lead Generation Engine v4.0
NAME=$1
URL=$2
EMAIL=$3
echo "[*] Initializing Prospect Analysis for: $NAME"
SCORE=$(curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=$URL&strategy=mobile" | jq '.lighthouseResult.categories.performance.score' | awk '{print int($1*100)}')
HTML=$(curl -sL "$URL")
ISSUES=""
[ -z "$(echo "$HTML" | grep -i "viewport")" ] && ISSUES="$ISSUES | No Mobile Viewport"
[ -z "$(echo "$HTML" | grep -i "https")" ] && ISSUES="$ISSUES | No SSL"
[ "$SCORE" -lt 50 ] && ISSUES="$ISSUES | Slow Loading ($SCORE/100)"
STATUS="Cold"; [ "$SCORE" -lt 60 ] && STATUS="Hot Prospect"
echo "$NAME|$URL|$EMAIL|$SCORE|$STATUS|$ISSUES" >> leads_pipeline.csv
echo "[+] Logged to leads_pipeline.csv. Status: $STATUS"