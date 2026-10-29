> Historical implementation notes. For current installed-system status and public source availability, see [Status](../../docs/STATUS.md). Referenced implementation files may be absent from this documentation/shell snapshot.

# System installation from independent recovery

The first installer is an SSH-triggered, on-device transaction. It reads a
private bundle staged on onboard p12; flashing does not depend on streaming
images from the host. A recovery package browser/update.zip interface is not
implemented yet. The same transaction is intended to back future Install/Update
and Restore Backup menu actions after normal installation is validated.

`prepare-system-payloads.py` assembles complete p4/p10 images and their original
rollback copies privately. `prepare-system-installer.py` pins the script to their
hashes, eMMC CID, board/layout, and preserved LK/U-Boot/recovery hashes.

The generated script requires independent recovery, a matching current boot ID,
RAM PID1/root, adequate battery and USB power, unmounted p4/p10, verified backups
and an unchanged installed baseline. `--check BOOT_UUID` checks these without
writing system partitions. A committed install writes p10 then p4, verifies full
readbacks, and rechecks recovery. It never reboots automatically.

On an error after writing begins, it restores dirty partitions from onboard
backups and verifies their full hashes. A rollback failure returns exit 3 and
requires staying in recovery. Interrupted/power-loss transactions can be restored
using the same staged script with `--rollback-reviewed-buildroot BOOT_UUID`,
after re-entering and verifying independent recovery. Original host backups
remain available independently of the onboard staging files.

Write scope is p4 and p10 only. Preservation checks read boot0, p2 and the
recovery FIT on p11 with a read-only, noload mount. The existing onboard library,
notes and calibration are not rewritten by the transaction. Staging adds files
under `.adds/kobo-lab/buildroot-install-v9` on p12, including private rollback
images; these must not be published as firmware packages.

`test-installer.py` exercises 16 normal/fault paths using transformed scripts,
64 KiB regular files and fake mounts. This validates failure/rollback logic;
actual filesystem, flash performance and normal boot need device validation.
