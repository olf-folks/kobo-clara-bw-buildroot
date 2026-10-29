# Investigation and implementation journal

This is a retrospective of our reader, not a universal flashing recipe.
Sources are linked in [Sources and credits](SOURCES-AND-CREDITS.md).

## 1. Start inside the stock system

We first built a native Linux framebuffer/touch interface while retaining the
stock system. A supervisor paused Nickel and its watchdog, and restored them
when the interface exited. This let us work on reading, notes, setup, file
management and audio before changing the production root filesystem.
FBInk provided the e-ink drawing/rotation foundation. NickelDBus supplied
stock-system integration during this phase. These are Linux C applications,
not bare-metal display or touch drivers.

## 2. Identify the actual boot chain

Read-only captures established the N365B hardware configuration, storage map,
stock kernel and hardware boot areas. LK is in eMMC hardware boot0, while GPT
p2 contains U-Boot and p4 contains the normal kernel FIT. The partition named
bl2 was not the active LK image on our unit.

We reviewed published MediaTek/Kobo work, then found the kos software installer
for Clara Colour. Its LK branch patch plus GFH digest repair, rebuilt U-Boot
without FIT signature enforcement, and rebuilt vendor kernel supplied the
critical software route. We adapted and checked it against our BW images;
we did not run the Colour installer unchanged. In particular, its formatting
of userdata was inappropriate for our preservation goals.

## 3. Prove a custom kernel first

Host-side preparation checked the exact original LK image and unique patch
pattern, changed only the intended branch/digest bytes, and retained the
component-integrity mechanism. The unsigned U-Boot and vendor 4.9.77 kernel
were built with the BW device tree and checked FIT components. After owner
authorization, the backed-up boot regions and normal kernel were written and
read back. A normal boot proved the new kernel and kexec capability.

This was a persistent software modification from root Linux. We did not
establish a generic BROM/fastboot exploit, modify eFuses, or prove AArch64 boot.

## 4. Establish independent recovery

A separate initramfs recovery was placed on the recovery partition, with a
U-Boot selection path, USB ACM diagnostics and RNDIS SSH. Recovery boots its
own RAM root and leaves system/userdata unmounted until explicitly needed.
The power button navigates its e-ink menu. Display rotation/font were adjusted
with owner feedback; the screen log viewer was physically checked.

USB troubleshooting mattered: the stock computer prompt could be hidden while
our custom menu was active, and some cables did not provide usable data.
A changed e-ink image is not required for a system to be running, since the
panel retains its previous contents. We verified transport and process state.

## 5. Integrate Buildroot in RAM

Buildroot 2026.08, ARM32 Cortex-A53 hard-float, Arm GCC 11.2 and glibc 2.34 were
used with the vendor kernel. The rootfs was trial-booted in RAM before writing
p10. Hardware integration required verified firmware/calibration, kernel
modules, WMT startup, display services, waveform access and USB gadget setup.

We kept vendor ELF dependencies in an isolated runtime and audited dependency
closures and strong symbols rather than replacing Buildroot's base libc.
Actual startup, radio operation and device tests supplemented the ABI audit.
The existing onboard books/notes were reused, explaining why the library was
already populated in the new system.

## 6. Fix hardware and application regressions

Successive trials repaired DHCP sandbox compatibility, libgit2 notes sync,
warmth direction, Bluetooth service startup and audio routing. A laptop served
as the Bluetooth audio sink when headphones were unavailable. The owner heard
audio and checked play/pause, reconnect, disconnect and Forget Device.

Power testing took longer than expected. The kernel power-off hook performed
PMIC I2C too late, with interrupts disabled; the patch moves the existing
operation to power-off preparation. Suspend needed panel timer settling and
radio quiescing. Extended sleep and a shutdown-to-recovery cycle were proven
before committing the rootfs. Details are in [Problems and fixes](FIXES.md).

## 7. Back up, fault-test and install locally

Full normal-kernel and rootfs backups were copied over USB, decompressed and
hashed, then compared with independent full device reads. A later checksum
mismatch was not bypassed: evidence showed an extra stock rootfs mount before
recovery. A fresh full backup and independent matching read became the rollback
baseline, while the older backup was retained.

The installer was tested against 16 simulated cases including wrong device,
bad input, mounted root, short writes, decompressor failure and rollback failure.
New and old compressed partition payloads were staged on onboard storage.
SSH started the local transaction; it did not stream the flash contents.

From independent recovery, the installer wrote p10, then p4, verified full
partition hashes, and rechecked boot0, U-Boot and recovery preservation. A
second read after sync/cache drop matched. Existing userdata was retained.

## 8. First installed boot and continuing validation

Normal boot now starts Buildroot directly from internal eMMC. Installed Wi-Fi,
strict SSH, HTTPS and temporary file transfer passed; the owner reports the
interface working. Normal restart preserved the root device, SSH key and Wi-Fi
configuration, but exposed a reconnect issue documented in [Status](STATUS.md).
This remains a development project, not a completed generic firmware release.
