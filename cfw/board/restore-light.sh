#!/bin/sh
# Restore only numeric native UI settings. Never source an onboard file.
set -eu
settings=${KOBO_LAB_APP_DIR:-/mnt/onboard/.adds/kobo-lab}/ui-settings
light=/sys/class/backlight/lm3630a_led
[ -r "$settings" ] && [ -d "$light" ] || exit 0
brightness=
warmth=
while IFS='=' read -r key value; do
    case "$value" in ''|*[!0-9]*) continue;; esac
    # Bound the length before shell arithmetic on untrusted onboard text.
    [ "${#value}" -le 3 ] || continue
    # Canonical decimal only, avoiding octal interpretation and alternate forms.
    case "$value" in 0|[1-9]|[1-9][0-9]|100) :;; *) continue;; esac
    case "$key" in brightness) brightness=$value;; warmth) warmth=$value;; esac
done < "$settings"
if [ -n "$warmth" ] && [ -r "$light/max_color" ]; then
    maximum=$(cat "$light/max_color")
    case "$maximum" in ''|*[!0-9]*) maximum=0;; esac
    if [ "${#maximum}" -le 5 ] && [ "$maximum" -gt 0 ]; then
        printf '%s\n' "$(( ((100 - warmth) * maximum + 50) / 100 ))" > "$light/color"
    fi
fi
[ -z "$brightness" ] || printf '%s\n' "$brightness" > "$light/brightness"
