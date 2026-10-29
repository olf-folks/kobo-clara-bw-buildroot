#!/bin/sh
# Run in existing worker chroot; no deployment or infrastructure changes.
set -eu
base=/work/kobo-kernel/20261028
job=$base/recovery
source=/tmp/kobo-recovery-uboot-src-v2
out=/tmp/kobo-recovery-uboot-out-v2
prefix=$base/toolchains/arm-kobo-linux-gnueabihf/bin/arm-kobo-linux-gnueabihf-
[ ! -e "$source" ] && [ ! -e "$out" ]
cp -a /tmp/kobo-uboot-src-20261028/u-boot "$source"
patch -d "$source" -p1 < "$job/independent-recovery.patch"
export PATH="/tmp/kobo-uboot-src-20261028/host-tools/usr/bin:$PATH"
export BISON_PKGDATADIR=/tmp/kobo-uboot-src-20261028/host-tools/usr/share/bison
export PATH="$out/scripts/dtc:$PATH"
mkdir "$out"
cp /tmp/kobo-uboot-out-20261028/.config "$out/.config"
make -C "$source" O="$out" CROSS_COMPILE="$prefix" SHELL=/bin/bash HOSTCFLAGS='-O2 -fcommon' olddefconfig
make -C "$source" O="$out" CROSS_COMPILE="$prefix" SHELL=/bin/bash HOSTCFLAGS='-O2 -fcommon' CONFIG_PYLIBFDT= -j4 u-boot.bin tools
mkdir -p "$job/artifacts"
cp "$out/u-boot.bin" "$job/artifacts/"
cp "$out/.config" "$job/artifacts/uboot.config"
cp "$base/unsigned-uboot.its" "$job/artifacts/"
cd "$job/artifacts"
"$out/tools/mkimage" -f unsigned-uboot.its UNTESTED-recovery-u-boot.itb
sha256sum u-boot.bin uboot.config UNTESTED-recovery-u-boot.itb > SHA256SUMS
printf '%s\n' 'RECOVERY U-BOOT BUILD COMPLETE. UNTESTED; nothing installed.'
