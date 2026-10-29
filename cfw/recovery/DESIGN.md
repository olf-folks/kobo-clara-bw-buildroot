> Historical implementation notes. For current installed-system status and public source availability, see [Status](../../docs/STATUS.md). Referenced implementation files may be absent from this documentation/shell snapshot.

# Independent N365B recovery before userspace replacement

Status: source-checked design, not installed or boot-tested. Continue the main
Buildroot build; do not repurpose its running output tree for recovery.

## Purpose

Boot a known-good vendor kernel and small recovery userspace independently of
the experimental kernel and production rootfs. Provide local USB access,
inspection, image upload, explicit verified restoration and later RAM-only
kernel trials. Recovery must never start Kobo's factory-reset scripts.

## Evidence on this device and in its applicable U-Boot source

- Current custom 4.9.77 boots, root SSH has worked, CONFIG_KEXEC=y.
- Kernel has initrd/gzip, devtmpfs, USB gadget/configfs, ACM and RNDIS built in.
  Compiled support is not proof that gadget setup or kexec handoff works.
- Verified backup includes the complete 1 GiB p11 recovery partition.
- U-Boot source is pinned to koreader-os/u-boot commit
  bdd69414357ce5dff357d48a33ebe64cbcfeeef6.
- common/bootm.c:758-786 uses LK-supplied powerkey/USB flags to select p11
  rootdev. It does not unconditionally select a different kernel.
- common/bootm.c:90-169 can load a recovery FIT, but the call at 179-194 is
  conditional on normal kernel discovery failure. A valid kernel that hangs
  is not covered by that fallback.
- include/configs/mt8113_tp1.h:55-75 normally loads boot_a before bootm.
  A recovery selector must run before normal FIT discovery, and preserve the
  vendor HWCFG, reserved-memory, DT selection and boot-argument setup.

## Proposed layout and behavior

1. Keep LK unchanged. Prepare a narrowly scoped U-Boot change that selects a
   dedicated recovery FIT when the verified recovery gesture is present.
   The selector must not depend on Linux, p10, a working test kernel, saveenv,
   or a flag that can only be cleared from the failed test kernel.
2. Keep the recovery FIT and recovery rootfs on p11. A bundled initramfs is
   preferred to avoid depending on a second filesystem after the kernel loads.
   Use the booted vendor 4.9.77 baseline and captured board DTs. Reserve p4 for
   ordinary/test boot and leave p10/p12 untouched by recovery startup.
3. Recovery init mounts proc/sys/dev/run and starts USB ACM plus USB network
   and key-only SSH. Start from static/minimal tools where practical. Check
   current UDC requirements before configuring the gadget; do not assume
   generic configfs alone works on this MediaTek kernel.
4. Read-only storage is the default. Never autoformat, restore or export a
   live writable filesystem via USB mass storage. No automatic battery gauge
   reset, radio startup, sleep or power-off policy belongs in initial recovery.
5. Provide image inspection and explicit restore procedures using known input
   lengths, device identity checks, pre-write hashes and complete readback.
   Keep original boot-chain images and manifests available on host/onboard.
6. Later add explicit kexec loading of a test kernel/DT/initramfs from RAM.
   Kexec execution and platform handoff are not proven yet. A hung test may
   require a physical power cycle followed by the recovery gesture.

## Validation order / smallest first experiment

A. Build a separate minimal recovery userspace archive on the host/worker.
   Inspect its files, init, architecture, dependencies and absence of factory
   reset code. Test userspace tools in an isolated directory under the running
   kernel before arranging a boot. Do not execute its PID1 init on the reader.
B. Prepare U-Boot selection patch and FIT offline, including bounds checks for
   FIT/initramfs/DT load addresses and vendor reserved RAM. Review diff, hashes,
   backup and rollback procedure before persistent writes or a recovery boot.
C. First recovery boot uses only the known-good kernel. Expected: independent
   build marker, recovery PID1, USB network/ACM, authenticated root access;
   p10/p12 remain unmounted and unchanged. Verify ordinary boot still works.
D. Only after both boot paths work, attempt a separately reviewed kexec trial
   of the same known-good kernel before trying Linux 7 or other experimental
   kernels. Preserve a physical route to recovery after a hang.

## Limits

Recovery cannot repair an LK/U-Boot failure if they cannot reach its selector,
nor guarantee repair of damaged eMMC or PMIC/power failure. USB cable reliability
still matters. The existing Bluetooth console is a Linux application service,
not established early-boot access; do not make it the sole recovery transport.
No claim that stock recovery automatically rescues a valid but broken kernel.

## Fastboot interface requested by owner

Investigate a small Linux userspace fastboot responder in recovery, using the
known-good vendor USB stack and FunctionFS (compiled in the current kernel).
This is distinct from enabling U-Boot's fastboot USB gadget: its source exists,
but CONFIG_FASTBOOT/USB_FUNCTION_FASTBOOT are not enabled in the installed
rebuilt U-Boot configuration. Neither transport is demonstrated on this board.
AOSP fastbootd establishes that fastboot can run in recovery userspace; its
Android HAL dependencies make it unsuitable as an assumed drop-in Buildroot
component. Evaluate a portable implementation before writing a new protocol.

Initial validation exposes devices/getvar/download only, with no writes.
Then add an explicit boot_a-only flash backend accepting the Kobo FIT format,
checking bounds, FIT component hashes and a retained rollback copy, followed
by full readback. Reject bootloader, recovery, partition table and erase/flashall
operations in the initial tool. Standard client compatibility must be tested.
Fastboot boot is a separate feature requiring a proven kexec/platform handoff;
implementing flash does not imply temporary boot works.

Reference: https://source.android.com/docs/core/architecture/bootloader/fastbootd

## Countdown selector investigation — 2026-10-28

Owner asked for a GRUB-like timed choice of ordinary boot versus recovery.
U-Boot can supply the selector directly; an additional executable shim is not
required. The built uboot.config enables CONFIG_CMD_BOOTMENU, CONFIG_MENU and
CONFIG_BOOTDELAY=2. However, this board's environment has stdin/stdout/stderr
set to serial. cmd/bootmenu.c renders an ANSI terminal menu and consumes
console arrow/Enter keys; this does not establish E Ink display or power-button
input support.

The vendor common/autoboot.c __abortboot() forcibly sets bootdelay=1, replaces
the outer countdown loop with do/while(0), and waits only about 10 ms in the
inner loop. Changing CONFIG_BOOTDELAY alone will not produce the intended
countdown. A board selector must preserve watchdog servicing and ordinary
boot, and poll a proven physical input rather than repeatedly reading the
LK boot-time powerkey_status snapshot. Keep the power+USB recovery gesture
independent of any Linux menu or normal kernel. Inspect PMIC live button reads
and display initialization before promising an on-panel countdown. A minimal
recovery Linux menu is a possible later interface, but depends on booting that
kernel and does not replace the independent bootloader recovery selector.

## Minimal archive prototype — 2026-10-28

build-initramfs.py builds an offline newc+gzip archive using selected BusyBox,
Dropbear, ARM loader and recursively inspected DT_NEEDED dependencies from the
completed Buildroot tarball. The local build/recovery-20261028/ archive is about
1.5 MB compressed. It includes only the owner's public SSH key. Private keys
and host keys are not embedded. A RAM-only host key is generated at startup;
its fingerprint needs an authenticated out-of-band validation path before use.

The prototype PID1 has a PID guard, mounts only virtual filesystems and RAM,
and never starts stock init or mounts internal storage. USB helper proposes
configfs ACM+RNDIS and static 192.168.77.2/30; host uses 192.168.77.1/30.
ACM has no unauthenticated shell. Kernel support is present, but controller
binding, enumeration, interface naming and authenticated access are untested.
No DHCP server is included. No recovery FIT or boot selector is installed.

Archive construction, ARM ELF identity/dependency inspection, shell syntax,
and host cpio archive listing passed. These checks do not validate ARM runtime,
Dropbear account policy, USB hardware, PID1 behavior or kernel handoff. Before
boot packaging, remove skip_initramfs from the recovery boot arguments, supply
rdinit=/init and prove initrd handling/load ranges in this vendor boot chain.

## Runtime and packaging evidence — 2026-10-28

- `build/recovery-20261028/runtime-results.json`: QEMU/PRoot runs the ARM
  userspace, accepts the authorized key and command, rejects an unlisted key
  and password login. User-namespace-only emulation initially failed setgroups;
  PRoot allowed completing the account/session checks.
- `device-runtime-test.txt`: the actual Kobo 4.9.77 kernel runs BusyBox and
  Dropbear from `/tmp/kobo-independent-recovery-test`; key generation passes,
  `/init` rejects a non-PID1 invocation. No virtual or internal filesystem was
  mounted by this test. Device nodes were subsequently supplied in the test
  directory; init supplies them through devtmpfs in a real recovery boot.
- `device-ssh-result.json`: real target public-key authentication, pinned
  server host key, command execution, uid/gid 0 and BusyBox checksum all pass.
  The first 10-second handshake deadline expired; a 30-second deadline passed.
  This tests Wi-Fi transport into a chroot, not recovery boot or USB access.
- `device-usb-unbound-test.txt`: configfs instantiates ACM and RNDIS and links
  them into a composite configuration on the actual device. The controller
  remains unbound. Probe objects are removed afterward. Enumeration and a
  USB network connection remain unverified.
- `build-fit.py` produces `fit/UNTESTED-recovery.itb` (~7.9 MB) using the
  previously booted kernel bytes, both captured DT variants and the archive.
  It changes only each DT's `/chosen/bootargs`, supplying `rdinit=/init`,
  removing `skip_initramfs` and preventing a production root argument.
  Independent extraction verifies all four payload SHA-256 hashes against
  the input files and FIT hash nodes. Kernel/DT/ramdisk load addresses are
  0x40008000/0x44000000/0x46000000. The proposed FIT read is bounded to 16 MiB
  at 0x41000000. These low-RAM ranges avoid fixed DT reservations, but live
  vendor hidden-memory, U-Boot relocation and decompressor behavior still need
  review before boot. The existing conf@1/conf@2 and ntx_conf convention is
  retained for vendor DT selection.

No bootloader, recovery partition or production rootfs has been written.
The owner requested opening the installed custom menu during testing; PID
1278 and repeated guard `menu_awake=1 idle_seconds=0` confirm awake inhibition.

## Selector build and USB binding — 2026-10-28

Pinned U-Boot patch, worker build script, actual-source host fault tests and
review notes are now in this directory. The built candidate changes only the
normal command dispatch and adds an early power+USB recovery path. It checks
LK argument magic, hwcfg board/layout, a 16 MiB maximum FIT length and FIT
hashes before recovery boot. Recovery failure stops without stock-reset
fallback. Existing normal boot remains the default. Kernel and LK are unchanged.
The captured current p2 rollback hash matches the previously installed build.
See REVIEW.md and build/recovery-20261028/uboot/ for exact artifacts/evidence.

Live p11 SHA256 matches the independently extracted verified backup exactly:
5b594020e9648a30a22fc74ee1379ff78983e2b92b008f7b92b94aed594879aa.
Its offline copy with the recovery FIT added passes exact file readback and
all five filesystem checks. It is a placement test, not an image to flash
wholesale. Compressed-backup metadata differs from the old manifest, but the
entire decompressed image matches the recorded raw length/hash and gzip CRC;
backup-verification.json preserves both observations without editing the old
manifest.

A live, temporary composite gadget now binds successfully, creates /dev/ttyGS0
and configures 192.168.77.2/30. The kernel uses rndis0, not usb0; recovery-usb
now reads the function's actual ifname from configfs. This fix is in the rebuilt
archive/FIT and refreshed offline p11 test. The test always unbinds and removes
its gadget afterward. The controller reported not attached: physical cable
enumeration, host address setup and USB SSH are still required. Owner has been
asked to connect a USB data cable; the installed menu remains awake.
