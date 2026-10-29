#!/bin/sh
# Run only inside the worker build chroot. Produces host-side artifacts only.
set -eu
base=/work/kobo-kernel/20261028
source=${KOBO_KERNEL_SOURCE:-$base/linux/v4.9}
out=${KOBO_KERNEL_OUTPUT:-$base/out-kexec}
prefix=$base/toolchains/arm-kobo-linux-gnueabihf/bin/arm-kobo-linux-gnueabihf-
test -f "$source/Makefile"
test -x "${prefix}gcc"
mkdir -p "$out" "$base/artifacts"
cp "$base/running.config" "$out/.config"
"$source/scripts/config" --file "$out/.config" --enable KEXEC
"${prefix}gcc" --version | head -n 1
make -C "$source" O="$out" ARCH=arm CROSS_COMPILE="$prefix" \
    HOSTCFLAGS='-O2 -fcommon' olddefconfig
python3 - "$base/running.config" "$out/.config" > "$base/artifacts/config.diff" <<'PY'
from pathlib import Path
import sys
def config(path):
    values = {}
    for line in Path(path).read_text().splitlines():
        if line.startswith('CONFIG_') and '=' in line:
            key, value = line.split('=', 1)
            values[key] = value
        elif line.startswith('# CONFIG_') and line.endswith(' is not set'):
            values[line[2:-11]] = 'n'
    return values
before, after = map(config, sys.argv[1:])
for key in sorted(set(before) | set(after)):
    if before.get(key) != after.get(key):
        print(f'{key}: {before.get(key, "absent")} -> {after.get(key, "absent")}')
PY
grep '^CONFIG_KEXEC=y$' "$out/.config"
make -C "$source" O="$out" ARCH=arm CROSS_COMPILE="$prefix" \
    HOSTCFLAGS='-O2 -fcommon' \
    CFLAGS_cyttsp5_device_access.o='-Wno-error=misleading-indentation' \
    CFLAGS_hwtcon_core.o='-Wno-error=misleading-indentation' \
    CFLAGS_eas_ctrl.o='-Wno-error=stringop-overflow' -j8 zImage dtbs
cp "$out/arch/arm/boot/zImage" "$base/artifacts/zImage"
cp "$out/arch/arm/boot/dts/mediatek/aud8113tp1-E60T00-D0x00-BW.dtb" \
    "$base/artifacts/clara-bw.dtb"
cp "$out/.config" "$base/artifacts/kernel.config"
cp "$out/System.map" "$base/artifacts/System.map"
cp "$out/vmlinux" "$base/artifacts/vmlinux"
cd "$base/artifacts"
sha256sum zImage clara-bw.dtb kernel.config System.map vmlinux > SHA256SUMS
printf '%s\n' 'BUILD COMPLETE; artifacts only. Nothing installed on the reader.'
