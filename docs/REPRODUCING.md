# Reproducing the work: developer workflow

This is a staged workflow, not a copy/paste install recipe. The public snapshot
is documentation plus selected shell scripts; it does not yet contain all
application sources, patch generators, recovery code or private hardware inputs
needed for a complete build. A build recipe referencing those missing inputs
must not be presented as reproducible today.

## Establish a stock baseline

Record the actual model/revision, firmware, HWCONFIG, kernel command line,
partition map and sizes. Acquire authorized root access using a method
appropriate for that stock firmware. Our early work started from stock root
Linux; this repository does not supply a universal root-access exploit.

Back up active boot regions and normal kernel/system partitions. Keep originals
outside the reader. Verify compressed archives by decompression and full raw
hash; independently reread the device regions to check the copy. Account for
an ordinary rootfs mount changing filesystem bytes. A mismatch is a reason to
re-establish the backup baseline, not remove integrity checks.

## Build the kernel and bootloader

Use the pinned [Kobo and kos sources](SOURCES-AND-CREDITS.md). The included
[`build-unsigned-uboot.sh`](../research/boot-chain/2026-10-27/build-unsigned-uboot.sh)
and [`build-vendor-kexec.sh`](../research/boot-chain/2026-10-27/build-vendor-kexec.sh)
record our build commands and toolchain expectations. They contain local build
workspace paths that must be adapted. The `.its` inputs and LK preparation
Python source are not in this shell/documentation snapshot.

Choose the **BW E60T00** DT, retain reserved memory/HWCONFIG/NTX handoff
requirements, enable kexec and maintain module ABI compatibility. The running
kernel stays ARM32 4.9.77. Do not substitute a Colour DT or infer AArch64 boot
support from the Cortex-A53 CPU label.

The historical [`commit-first-kernel-trial.sh`](../research/boot-chain/2026-10-27/commit-first-kernel-trial.sh)
is published as an auditable record of the first transaction. It is pinned to
that experiment's inputs and is not a generic flashing utility or the later
Buildroot system installer. Do not remove its guards to force it onto a
nonmatching device. Its companion preparation programs and private manifest
are not included.

## Establish recovery before rootfs replacement

Build and test an independent initramfs with USB serial identity and SSH,
screen/status and button menu. Confirm that it boots without the installed
rootfs and can leave production storage unmounted. Verify actual entry from
poweroff. Preserve an earlier known-good recovery image while developing a new
one. See [Boot and recovery](BOOT-AND-RECOVERY.md).

## Assemble and trial Buildroot

The working build used Buildroot 2026.08, Cortex-A53 ARM hard-float, Arm GCC
11.2 and glibc 2.34. Our external-tree defconfig and complete application source
staging will need publication before this becomes a complete public build.
The included [post-build script](../cfw/board/post-build.sh) illustrates the
credential checks and board startup expectations, rather than supplying all
its inputs.

Extract required vendor hardware assets from your own authorized device or
firmware. Keep firmware, calibration, SSH authorization and Wi-Fi settings in a
private overlay, outside public sources. Audit ELF dependency/symbol closure,
preserve required SONAME aliases, and verify actual runtime startup. Do not
replace the base libc with vendor files just to satisfy one daemon.

Trial boot the rootfs in RAM via the tested custom kernel/recovery path. Test
display/touch, onboard files, Wi-Fi, SSH, notes, lights, Bluetooth/audio and
power. See [fixes](FIXES.md) for integration traps; static ABI checks alone do
not establish usable hardware.

## Install only from a tested recovery

Prepare per-device payloads and rollback files from independently verified
backups. Our transaction staged four compressed partition payloads on onboard
storage, checked them locally, wrote the rootfs then normal kernel, and
verified full regions plus recovery preservation. It never reformatted
userdata and never automatically rebooted after a failed rollback.

The first-install backend is still tied to reviewed image hashes and layout.
Its package builder and template require their own source publication and
parameterization; there is no supported generic `update.zip` release yet.
Never reuse another reader's calibration, credentials or CID-pinned manifest.

After normal boot, verify actual root device in mountinfo, kernel identity,
automatic services, persistent SSH identity, saved network state and hardware.
Repeat tests after restart and poweroff. Keep recovery and verified rollback
inputs available throughout. Read [current limitations](STATUS.md) before
relying on unattended startup or assuming installed-system power testing is complete.
