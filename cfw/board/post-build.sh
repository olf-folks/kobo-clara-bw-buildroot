#!/bin/sh
# Buildroot normalizes overlay permissions; restore owner-only provisioning.
set -eu
target=$1
[ -d "$target/etc" ] && [ -d "$target/usr/lib/kobo-lab" ]
[ -f "$target/etc/kobo-buildroot" ]
[ -s "$target/root/.ssh/authorized_keys" ]
[ -s "$target/etc/wpa_supplicant.conf" ]
[ -s "$target/etc/kobo/hardware.sha256" ]
[ -x "$target/usr/lib/kobo-lab/start-hardware" ]
[ ! -L "$target/root" ] && [ ! -L "$target/root/.ssh" ]
chmod 700 "$target/root" "$target/root/.ssh"
chmod 600 "$target/root/.ssh/authorized_keys" "$target/etc/wpa_supplicant.conf"
find "$target/data/nvram" -type d -exec chmod 700 {} +
find "$target/data/nvram" -type f -exec chmod 600 {} +
# Integrity covers the private hardware/calibration payload, never Wi-Fi keys.
(cd "$target" && sha256sum -c etc/kobo/hardware.sha256)
# Do not allow an accidentally staged private SSH key into the image.
if grep -q 'PRIVATE KEY' "$target/root/.ssh/authorized_keys"; then
    echo 'Invalid authorized_keys input' >&2
    exit 1
fi
