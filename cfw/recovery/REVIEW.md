> Historical implementation notes. For current installed-system status and public source availability, see [Status](../../docs/STATUS.md). Referenced implementation files may be absent from this documentation/shell snapshot.

# Independent recovery boot trial — installed and boot verified

## Current verified state — 2026-10-28

The owner authorized installation and boot trials with “full send”. The text
below this section preserves the original reviewed transaction and preflight
findings; its prospective/untested statements are historical, not current state.
Do not rerun the completed installer.

U-Boot was installed and ordinary boot through it passed. Independent recovery
v1 booted, then v2 was installed with fresh read-only file readback. Current v2
FIT SHA256 is
`9ca6b6b6f50e38e42c9297827f35a3a0554b7d08516f4f5fbfb66d9aeac1f7d2`.
V2 includes the portrait power-button menu and exact private panel waveform.

Fresh verification of boot `a8a6d98d-5217-4950-911e-7fa9f4b8b0fd` proves:

- Prototype 2, known-good 4.9.77 kernel, `/bin/sh /init` as PID1, RAM root.
- Only virtual filesystems mounted; p10/p12 unmounted and all their diskstats
  counters zero. Whole-device write counters were also zero at inspection.
- ACM identity supplies the fresh SSH host key; pinned-key root authentication,
  923280-byte hash-verified transfer and another 20 seconds of link checks pass.
- Menu runs at 1072x1448 on event2; key-handling and safe-confirmation self-tests
  pass on device. Owner previously confirmed navigation and readable log.
- Complete p2 hash remains
  `79a13160e9076768f0184307324cbd37c73bbf627e7af50b1dd9385137d1e64a`.

Evidence is under `build/recovery-20261028/v2/`: `usb-ssh-validation.json`,
`independent-boot-verification.txt`, `final-runtime-check.txt`, and the earlier
`device-update-readback.txt`. The JSON transport report's original scope field
says independent boot untested; the separate PID1/boot evidence above supersedes
that stale wording. Build-time `status=BOOT-UNTESTED` is likewise a preserved
artifact label, not a runtime verdict.

Host ModemManager logs prove it temporarily probed ACM at 15:12:14–15:12:41;
the port is now released. No host service change was necessary. Current USB
history shows activation at ~8 seconds and no later disconnect through uptime
715 seconds. This proves stability of this observed boot, not repeated cold
boots. Owner reports ordinary reboot works; a coordinated final return with
host-side normal-root/menu verification remains outstanding. No p4 flash test
has been performed or included in this completed installation transaction.

## Original reviewed plan (historical)

The candidate is built and its exact packaged USB helper, activation module,
ARM userspace, serial identity output and key-authenticated USB SSH have passed
on the running Kobo kernel. It has not booted independently. No bootloader or
recovery-partition changes have been executed for this trial.

## Proposed changes

- Add one file, `/recovery/kobo-lab/recovery.itb`, to p11. This FIT bundles the
  already running vendor 4.9.77 kernel, captured device trees with recovery boot
  arguments, and minimal RAM-based userspace. It does not start stock init.
- Replace the U-Boot FIT prefix on p2 (381460 bytes), preserving the rest of the
  1 MiB partition. LK, normal kernel p4, main rootfs p10, userdata p12, TEE and
  eFuses are outside the write scope.
- U-Boot checks LK power+USB flags before reading the normal kernel. Recovery
  loads the dedicated p11 FIT with length and hash checks. A recovery load
  failure stops without invoking the stock factory-reset fallback. Ordinary
  boot retains its previous command and behavior.

The candidate adds no touch/display menu or countdown yet. Recovery entry uses
physical boot flags and does not depend on the normal kernel or userspace.

## Runtime evidence

`build/recovery-20261028/device-package-usb-ssh-result.json` records the exact
packaged helper test in a temporary chroot on the running kernel:

- ACM and RNDIS enumerate; the USB network route is directly through usb0.
- The host reads the newly generated public host key over USB ACM and pins it
  for SSH. Owner public-key authentication succeeds as uid/gid 0.
- A 923280-byte transfer matches SHA256
  7279ff319d5dd7f1d5bd1a6d8b2e44adbe7a6a0beadfb9bde3206ca4be7ca099.
- Test cleanup stops its SSH/serial processes, unloads the activation module,
  removes the gadget and unmounts its temporary virtual filesystems.

The activation module uses the existing vendor USB connect/disconnect APIs;
all seven imported symbol CRCs match the running kernel. It is included in the
archive, and the builder rejects an architecture, vermagic or symbol-CRC
mismatch. Serial output contains public identity information only, with no
interactive shell. Host keys exist only in RAM and change on each boot.

The spare cable produced successful enumeration. Holding the T420 hubs awake
and reversing the previous cable did not produce enumeration; earlier lack of
the stock connect prompt was not a valid cable diagnosis because the custom
menu pauses Nickel. Host hub power settings have returned to `auto`.

## Offline evidence

- U-Boot cross-build passed on node02 with unchanged configuration. Its actual
  selector passes fault-injected routing, board, size, read, FIT/hash and
  environment failures. Recovery failures never load the normal kernel.
- Every recovery FIT payload was independently extracted and its SHA256 checked
  against its input and embedded hash. Only /chosen/bootargs differs in the DTs.
- Kernel _end is 0x40f5ce7c, before the FIT buffer at 0x41000000. Initial DT and
  initramfs loads are 0x44000000/0x46000000; relocation limits are
  fdt_high=0x45000000 and initrd_high=0x47000000. Static reservations and observed
  vendor hidden memory do not overlap these ranges. Actual handoff is untested.
- A separate p11 image with the final FIT added passes exact file readback and
  all five e2fsck phases. This offline image must not be flashed wholesale.
- Generated installer and regular-file fault tests pass for bad inputs, file
  copy/remount failures, explicit and silent short writes, and rollback failure.

## Candidate and rollback identities

`build/recovery-20261028/stage/SHA256SUMS` pins all staged inputs and the exact
installer. Current complete p2 was captured read-only and verified:

- Original p2: 7dd9df4ded3ce65ce4a73115be98337b2f8295792142e30bcadbff627ce05b83
- New U-Boot FIT: 72448716a0041776c207746b02eb2af92c4827b96740c82b285e1b851bdf665a
- Expected complete p2 after prefix write:
  79a13160e9076768f0184307324cbd37c73bbf627e7af50b1dd9385137d1e64a
- Recovery FIT, 7957061 bytes:
  27decfe7feb55484e0e3040a1e52a26b34ffe803fadde3caa61ea2e696b00023
- Live p11 matches its extracted backup:
  5b594020e9648a30a22fc74ee1379ff78983e2b92b008f7b92b94aed594879aa

The original pre-userdata backup's compressed checksum/size metadata differs
from its manifest. Full gzip CRC and decompressed length/SHA256 match the
recorded raw image exactly; backup-verification.json preserves this finding
without changing the original manifest. Userdata was omitted as requested.

## Installation transaction and acceptance

The generated installer requires `--commit-reviewed-recovery`. It checks device
sizes, power, force_ro and every input/preimage hash. It adds the recovery FIT
on p11 and verifies it through a fresh read-only mount before touching p2.
Then it writes the U-Boot prefix and verifies the entire p2 hash. A failed
write/readback restores and hashes the complete captured current p2. The
installer never reboots. Its persistent log and rollback copy are under
`/mnt/onboard/.adds/kobo-lab/recovery-trial-20261028/`.

After owner approval of installation and the boot trial:

1. Install and verify the candidate; stop on any failure or uncertain readback.
2. Perform one ordinary reboot, verify SSH, kernel identity, custom menu and
   awake guard. This establishes that normal boot through the new U-Boot works.
3. Coordinate a physical recovery entry with the owner. Verify recovery PID1,
   independent build marker, USB ACM identity, pinned-key root SSH and no p10/p12
   mounts. Verify production-partition hashes remain stable during recovery.
4. Return to normal boot and verify the menu/awake guard again. Do not perform
   sleep tests, kexec, kernel replacement or fastboot flash experiments here.

This is an untested bootloader/recovery handoff. A bootloader failure before
Linux starts can prevent both boot paths; backups alone do not provide a proven
hardware recovery transport. Approval is needed before this persistent boot
trial. Ordinary builds and chroot tests do not prove it will boot.

Staging verification completed: all four staged SHA256 checks and installer
syntax pass on the Kobo. Current p2 still has its original captured hash,
battery reports 100, boot0 force_ro=1, and the custom menu/awake guard are
active. Temporary package-test mounts and activation module are absent.
Evidence: build/recovery-20261028/device-candidate-staged.txt. No installer or
reboot has been executed for this trial.

## Final acceptance — 2026-10-28

The owner selected normal reboot and confirmed the stock screen. The host then
found the reader at WLAN_ADDRESS_REDACTED on the new WLAN: MAC DEVICE_MAC_REDACTED and
its previously trusted SSH host key both match. Key-authenticated SSH confirms
boot ID `7abe128e-e80d-46fc-9f25-8b1f190a5a88`, stock init, p10 normal root,
p12 onboard mount, and unchanged installed p2 hash. This supersedes the pending
normal-return statement above. `PREVIOUS_BOOT_ID` in the old verification script
is an earlier saved normal-boot marker, not the immediately preceding recovery
boot; use the freshly observed recovery and normal boot IDs for this trial.

The custom menu was reopened (PID 1269). A subsequent check shows the failsafe
running and `menu_awake=1 idle_seconds=0`. Evidence:
`v2/normal-return-verification.txt`, `v2/normal-return-awake-menu.txt`, and
`v2/normal-return-awake-menu-confirmed.txt` under build/recovery-20261028.

| Goal requirement | Acceptance evidence |
| --- | --- |
| Known-good kernel and minimal independent userspace | V2 FIT payload manifest, live 4.9.77 identity, /init PID1 and RAM root in v2/independent-boot-verification.txt |
| Offline artifact preparation and verification | V2 FIT extracted-payload hashes, v2/p11-offline-check.txt filesystem check, installer-tests.json and uboot/selector-test.txt |
| Reviewed recovery boot path | Original reviewed transaction below the current-state section, owner's full-send authorization, installed p2 hash and device-install-independent-readback.txt |
| Independent boot and USB access | Fresh prototype-2 ACM identity, pinned-key root SSH, verified transfer and 20-second checks in v2/usb-ssh-validation.json |
| Safe runtime and production storage isolation | No block mounts and zero p10/p12 I/O counters in v2/independent-boot-verification.txt and v2/final-runtime-check.txt; menu self-tests and owner display/navigation checks |
| Normal return and awake custom menu | New normal boot ID, stock root and unchanged p2 in v2/normal-return-verification.txt; awake guard in v2/normal-return-awake-menu-confirmed.txt |

The independent recovery objective is satisfied. Production rootfs has not been
replaced. Kernel write/restore testing, cableless software recovery selection,
and Buildroot hardware integration are subsequent work, not validated by this
trial. Repeated cold boots and behavior after arbitrary hardware faults are
not claimed. Existing original rollback backup and v1 recovery file are retained.
The optional read-only audit interrupted by the normal reboot produced no
result and is not used as acceptance evidence.
