#!/bin/bash
CACHE="$HOME/.cache/waybar-weather"
CACHE_TTL=1800

# Actualizează cache-ul dacă e vechi
if [ ! -f "$CACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) )) -gt $CACHE_TTL ]; then
    DATA=$(curl -sf --max-time 5 "wttr.in/?format=j1" 2>/dev/null)
    if [ -n "$DATA" ]; then
        TEMP=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['temp_C'])")
        CODE=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['weatherCode'])")
        echo "$TEMP $CODE" > "$CACHE"
    fi
fi

[ ! -f "$CACHE" ] && echo "-- °C" && exit 0
read TEMP CODE < "$CACHE"

FRAME=$(( $(date +%s) % 4 ))

# Animații în funcție de cod meteo
# 113=senin, 116=parțial noros, 119/122=noros, 143/248/260=ceață
# 176..314=ploaie, 317..350=lapoviță, 353..395=ninsoare, 386..395=furtună
case "$CODE" in
    113)
        FRAMES=("✶" "✷" "✸" "✷")   # soare animat
        ;;
    116)
        FRAMES=("◑" "◒" "◐" "◓")   # parțial noros - rotire
        ;;
    119|122)
        FRAMES=("●" "◉" "●" "◉")   # noros
        ;;
    143|248|260)
        FRAMES=("░" "▒" "░" "▒")   # ceață
        ;;
    176|179|182|185|281|284|293|296|299|302|305|308|311|314)
        FRAMES=("╎" "┊" "╎" "┊")   # ploaie
        ;;
    317|320|323|326|329|332|335|338|350|362|365|374|377)
        FRAMES=("❄" "❅" "❆" "❄")   # ninsoare/lapoviță
        ;;
    386|389|392|395)
        FRAMES=("↯" "⌁" "↯" "⌁")   # furtună
        ;;
    *)
        FRAMES=("◌" "◍" "◌" "◍")   # default
        ;;
esac

echo "${TEMP}°C"
