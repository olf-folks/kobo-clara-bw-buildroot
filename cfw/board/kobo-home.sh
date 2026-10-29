#!/bin/sh
# The Buildroot home session owns the screen directly; it never launches Nickel.
app=/mnt/onboard/.adds/kobo-lab
export KOBO_LAB_APP_DIR="$app"
export KOBO_LAB_READER_ENGINE=/usr/lib/kobo-lab/kobo-reader-engine
export KOBO_LAB_READER_LIBS=/usr/lib/kobo-lab/reader/libs:/usr/lib/kobo-vendor
export KOBO_LAB_FIELDNOTES_SYNC=/usr/lib/kobo-lab/kobo-fieldnotes-sync
export KOBO_LAB_AUDIO_ENGINE=/usr/lib/kobo-lab/kobo-audio-engine
export KOBO_LAB_RUNTIME=buildroot
export GST_PLUGIN_PATH=/usr/lib/kobo-vendor/gstreamer-1.0
export LD_LIBRARY_PATH=/usr/lib/kobo-vendor
mkdir -p "$app/reader" /var/log
exec >> /var/log/kobo-home.log 2>&1
/usr/lib/kobo-lab/restore-light || echo "Saved frontlight settings could not be restored"
trap 'kill -TERM "$child" 2>/dev/null; exit 0' TERM INT
while :; do
    /usr/lib/kobo-lab/kobo-menu &
    child=$!
    wait "$child"
    result=$?
    case "$result" in
    42)
        printf 'SCAN\nQUIT\n' | LD_LIBRARY_PATH="$KOBO_LAB_READER_LIBS" "$KOBO_LAB_READER_ENGINE"
        ;;
    43) /usr/bin/kobo-sleep;;
    44) /sbin/poweroff; exit;;
    46) /sbin/reboot; exit;;
    47) /usr/bin/kobo-browser;;
    0|45) :;;
    *) echo "Menu exited with status $result; restarting"; sleep 2;;
    esac
done
