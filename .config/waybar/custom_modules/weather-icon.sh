#!/bin/bash
CACHE="$HOME/.cache/waybar-weather-full.json"
CACHE_TTL=1800

fetch_weather() {
    local age=99999
    [ -f "$CACHE" ] && age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if [ "$age" -gt "$CACHE_TTL" ]; then
        local data
        data=$(curl -sf --max-time 8 "wttr.in/?format=j1" 2>/dev/null)
        [ -n "$data" ] && echo "$data" > "$CACHE"
    fi
}

read_palette() {
    local ghost="$HOME/.config/ghostty/colors.conf"
    local aether="$HOME/.config/waybar/aether-colors.css"
    if [ -f "$ghost" ]; then
        export P_WARM=$(grep 'palette = 6='  "$ghost" | grep -oP '#[0-9a-fA-F]+')
        export P_LIGHT=$(grep 'palette = 7=' "$ghost" | grep -oP '#[0-9a-fA-F]+')
        export P_NEUTRAL=$(grep 'palette = 5=' "$ghost" | grep -oP '#[0-9a-fA-F]+')
        export P_MUTED=$(grep 'palette = 3='  "$ghost" | grep -oP '#[0-9a-fA-F]+')
        export P_DARK=$(grep 'palette = 2='  "$ghost" | grep -oP '#[0-9a-fA-F]+')
    fi
    [ -f "$aether" ] && export P_HL=$(grep 'highlight' "$aether" | grep -oP '#[0-9a-fA-F]+' | head -1)
    export P_WARM=${P_WARM:-#DCB22B}
    export P_LIGHT=${P_LIGHT:-#E5D08C}
    export P_NEUTRAL=${P_NEUTRAL:-#A4A4A1}
    export P_MUTED=${P_MUTED:-#727372}
    export P_DARK=${P_DARK:-#6C5A20}
    export P_HL=${P_HL:-#9E8113}
}

build_output() {
    fetch_weather
    [ ! -f "$CACHE" ] && echo '{"text":"?","class":"unknown","tooltip":"Weather unavailable"}' && return

    python3 - "$CACHE" "$1" <<'PYEOF'
import sys, json, os
from datetime import datetime

with open(sys.argv[1]) as f:
    data = json.load(f)

frame_idx = int(sys.argv[2])

cur  = data['current_condition'][0]
area = data['nearest_area'][0]
days = data['weather']

temp     = cur['temp_C']
feels    = cur['FeelsLikeC']
humidity = cur['humidity']
wind     = cur['windspeedKmph']
wind_dir = cur['winddir16Point']
code     = int(cur['weatherCode'])
desc     = cur['weatherDesc'][0]['value']
vis      = cur['visibility']

city    = area['areaName'][0]['value']
country = area['country'][0]['value']

# Wallust palette colors
c_warm    = os.environ.get('P_WARM',    '#DCB22B')
c_light   = os.environ.get('P_LIGHT',   '#E5D08C')
c_neutral = os.environ.get('P_NEUTRAL', '#A4A4A1')
c_muted   = os.environ.get('P_MUTED',   '#727372')
c_dark    = os.environ.get('P_DARK',    '#6C5A20')
c_hl      = os.environ.get('P_HL',      '#9E8113')

RAINY  = {176,179,182,185,281,284,293,296,299,302,305,308,311,314}
SNOWY  = {317,320,323,326,329,332,335,338,350,362,365,374,377}
STORMY = {386,389,392,395}

WEATHER = {
    113: ('sunny',         ['✦','✧','✦','✶'], c_warm),
    116: ('partly-cloudy', ['◑','◒','◐','◓'], c_light),
    119: ('cloudy',        ['●','◉','●','○'], c_neutral),
    122: ('cloudy',        ['●','◉','●','○'], c_neutral),
    143: ('foggy',         ['░','▒','░','▒'], c_muted),
    248: ('foggy',         ['░','▒','░','▒'], c_muted),
    260: ('foggy',         ['░','▒','░','▒'], c_muted),
}

if code in WEATHER:
    cls, frames, color = WEATHER[code]
elif code in RAINY:
    cls, frames, color = 'rainy',  ['╎','┊','╎','┆'], c_hl
elif code in SNOWY:
    cls, frames, color = 'snowy',  ['❄','❅','❆','❄'], c_light
elif code in STORMY:
    cls, frames, color = 'stormy', ['↯','⌁','↯','⚡'], c_dark
else:
    cls, frames, color = 'cloudy', ['●','◉','●','○'], c_neutral

icon = frames[frame_idx % 4]

def code_icon(c):
    c = int(c)
    if c == 113: return '✦'
    if c == 116: return '◑'
    if c in (119,122): return '●'
    if c in (143,248,260): return '░'
    if c in RAINY: return '╎'
    if c in SNOWY: return '❄'
    if c in STORMY: return '↯'
    return '●'

DAYS_EN = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
sep   = f'<span color="{c_muted}">──────────────────</span>'
now_h = datetime.now().hour

hourly = []
for h in days[0]['hourly']:
    if int(h['time']) // 100 >= now_h:
        hourly.append(h)
    if len(hourly) >= 4:
        break
if len(hourly) < 4 and len(days) > 1:
    for h in days[1]['hourly']:
        hourly.append(h)
        if len(hourly) >= 4:
            break

lines = []
lines.append(f'<span color="{c_muted}">📍</span> <b>{city}, {country}</b>')
lines.append(sep)
lines.append(f'<span color="{color}"><b>{icon}  {desc}</b></span>')
lines.append(f'<b>{temp}°C</b>  <span color="{c_muted}">feels like {feels}°C</span>')
lines.append(f'<span color="{c_hl}">💧 {humidity}%</span>  <span color="{c_neutral}">💨 {wind} km/h {wind_dir}</span>  <span color="{c_muted}">👁 {vis} km</span>')
lines.append(sep)
lines.append(f'<span color="{c_muted}">Hourly</span>')
for h in hourly:
    hh = int(h['time']) // 100
    lines.append(f'  {hh:02d}:00  {code_icon(h["weatherCode"])}  {h["tempC"]}°C')
lines.append(sep)
lines.append(f'<span color="{c_muted}">Forecast</span>')
for i, day in enumerate(days[:3]):
    dt = datetime.strptime(day['date'], '%Y-%m-%d')
    name = 'Today' if i == 0 else ('Tomorrow' if i == 1 else DAYS_EN[dt.weekday()])
    name = f'{name:<10}'
    d_icon = code_icon(day['hourly'][4]['weatherCode'])
    rain = max(int(h.get('chanceofrain','0')) for h in day['hourly'])
    rain_s = f'  <span color="{c_hl}">🌧 {rain}%</span>' if rain > 20 else ''
    lines.append(f'  {name}  {d_icon}  {day["mintempC"]}° / {day["maxtempC"]}°C{rain_s}')

print(json.dumps({'text': icon, 'class': cls, 'tooltip': '\n'.join(lines)}))
PYEOF
}

read_palette
i=0
while true; do
    build_output $i
    i=$(( i + 1 ))
    sleep 2
done
