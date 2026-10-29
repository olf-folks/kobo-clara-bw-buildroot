#!/bin/sh
# Worker chroot only. Builds files; never invokes an installer or device write.
set -eu
base=/work/kobo-kernel/20261028
source=/tmp/kobo-uboot-src-20261028/u-boot
out=/tmp/kobo-uboot-out-20261028
prefix=$base/toolchains/arm-kobo-linux-gnueabihf/bin/arm-kobo-linux-gnueabihf-
export PATH="/tmp/kobo-uboot-src-20261028/host-tools/usr/bin:$PATH"
export BISON_PKGDATADIR="/tmp/kobo-uboot-src-20261028/host-tools/usr/share/bison"
export PATH="$out/scripts/dtc:$PATH"
make -C "$source" O="$out" CROSS_COMPILE="$prefix" \
    SHELL=/bin/bash HOSTCFLAGS='-O2 -fcommon' mt8113_tp1_emmc_defconfig
cp "$out/.config" "$base/artifacts/uboot-baseline.config"
sed -i 's/^CONFIG_FIT_SIGNATURE=y$/# CONFIG_FIT_SIGNATURE is not set/' "$out/.config"
make -C "$source" O="$out" CROSS_COMPILE="$prefix" \
    SHELL=/bin/bash HOSTCFLAGS='-O2 -fcommon' olddefconfig
grep '^# CONFIG_FIT_SIGNATURE is not set$' "$out/.config"
make -C "$source" O="$out" CROSS_COMPILE="$prefix" \
    SHELL=/bin/bash HOSTCFLAGS='-O2 -fcommon' CONFIG_PYLIBFDT= -j2 u-boot.bin tools
cp "$out/u-boot.bin" "$base/artifacts/u-boot.bin"
cp "$out/.config" "$base/artifacts/uboot.config"
cd "$base/artifacts"
cp "$base/unsigned-uboot.its" "$base/vendor-kexec.its" .
"$out/tools/mkimage" -f unsigned-uboot.its UNTESTED-u-boot.itb
"$out/tools/mkimage" -f vendor-kexec.its UNTESTED-kernel.itb
sha256sum u-boot.bin UNTESTED-u-boot.itb UNTESTED-kernel.itb > BOOT-SHA256SUMS
printf '%s\n' 'BUILD COMPLETE; unsigned host artifacts only, never installed.'
