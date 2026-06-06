
#!/bin/bash
# Sovereign Lead Generation Engine v4.1 (Hardened)

NAME=$1
URL=$2
EMAIL=$3

# 1. THE GATEKEEPER: Prevent execution if you forget an argument
if [ -z "$NAME" ] || [ -z "$URL" ] || [ -z "$EMAIL" ]; then
    echo "[-] SYSTEM HALT: Missing parameters."
    echo "[*] Usage: ./lead_gen.sh \"Business Name\" \"https://target-url.com\" \"email@address.com\""
    exit 1
fi

echo "[*] Initializing Prospect Analysis for: $NAME"

# 2. THE EXTRACTOR: Fetch score with failure protection
SCORE=$(curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=$URL&strategy=mobile" | jq -r '.lighthouseResult.categories.performance.score' | awk '{print int($1*100)}')

# If Google's API throttles the request and returns empty, default to 0 to prevent bash math errors
if [ -z "$SCORE" ] || [ "$SCORE" == "0" ]; then 
    SCORE=0
    echo "[-] WARNING: PageSpeed API returned null. Defaulting score to 0."
fi

# 3. THE ANALYZER: Check technical health
HTML=$(curl -sL "$URL")
ISSUES=""

# Append issues cleanly using a comma delimiter
[ -z "$(echo "$HTML" | grep -i "viewport")" ] && ISSUES="No Mobile Viewport, "
if [[ "$URL" == http://* ]]; then ISSUES="${ISSUES}No SSL, "; fi
if [ "$SCORE" -lt 50 ]; then ISSUES="${ISSUES}Slow Loading ($SCORE/100), "; fi

# Strip the trailing comma for a clean database entry, or default to "None"
ISSUES=$(echo "$ISSUES" | sed 's/, $//')
[ -z "$ISSUES" ] && ISSUES="None"

# 4. THE CLASSIFIER
STATUS="Cold"
if [ "$SCORE" -lt 60 ]; then STATUS="Hot Prospect"; fi

# 5. THE INJECTOR: Push data to the public dashboard directory
echo "$NAME|$URL|$EMAIL|$SCORE|$STATUS|$ISSUES" >> docs/leads_pipeline.csv

echo "[+] Prospect Status: $STATUS"
echo "[+] Identified Issues: $ISSUES"
echo "[+] Logged successfully to docs/leads_pipeline.csv"