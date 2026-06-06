#!/bin/bash
# SMCodex v15.4 - Sovereign Recon Engine v3.0
# Requirements: sudo apt install jq

TARGET=$1
if [ -z "$TARGET" ]; then
	echo "Usage: $0 https://target-url.com"
	exit 1
fi

echo "--- Sovereign Audit Report: $TARGET ---"

# Extract Performance Metrics
API_URL="https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=$TARGET&strategy=mobile"
DATA=$(curl -s "$API_URL")

LCP=$(echo "$DATA" | jq -r '.loadingExperience.metrics.LARGEST_CONTENTFUL_PAINT_MS.category // "N/A"')
CLS=$(echo "$DATA" | jq -r '.loadingExperience.metrics.CUMULATIVE_LAYOUT_SHIFT_SCORE.category // "N/A"')
INP=$(echo "$DATA" | jq -r '.loadingExperience.metrics.INTERACTION_TO_NEXT_PAINT.category // "N/A"')
RAW_SCORE=$(echo "$DATA" | jq -r '.lighthouseResult.categories.performance.score // 0')
SCORE=$(awk -v s="$RAW_SCORE" 'BEGIN{printf "%d", s*100}')

echo "Performance Score: $SCORE/100"
echo "LCP (Speed): $LCP | CLS (Stability): $CLS | INP (Interactivity): $INP"

# Check Technical SEO
HTML=$(curl -sL "$TARGET")
echo "--- Technical Health ---"
[ -n "$(echo "$HTML" | grep -i "canonical")" ] && echo "[+] Canonical: OK" || echo "[-] Canonical: MISSING"
[ -n "$(echo "$HTML" | grep -i "viewport")" ] && echo "[+] Viewport: OK" || echo "[-] Viewport: MISSING"
[ -n "$(echo "$HTML" | grep -i "robots")" ] && echo "[+] Robots Meta: OK" || echo "[-] Robots Meta: MISSING"
[ -n "$(echo "$HTML" | grep -i "og:title")" ] && echo "[+] Open Graph: OK" || echo "[-] Open Graph: MISSING"