# Status: first installed Buildroot system

Recorded 2026-10-29 UTC. One owner-tested Clara BW N365B; no broader device
matrix is claimed. Buildroot integration v9 and the power-off-fixed vendor
kernel have been written to normal system/kernel partitions and booted.

| Feature | Evidence and limits |
|---|---|
| Normal eMMC boot | First boot and a subsequent normal restart verified; root device 179:10, ext4 read/write |
| Persistent SSH identity | Same private-key file hash and pinned public host identity after restart; key itself remains private |
| Display/touch/menu | Portrait interface; owner reports working after installation |
| Reader / onboard books | Owner tested reader in RAM and reports installed system working; userdata retained |
| Fieldnotes | Manual sync works in trial; owner accepts installed system; no scheduled sync |
| Frontlight warmth | Slider direction corrected and physically tested |
| Wi-Fi / SSH / HTTPS | WPA association, DHCP, strict pinned SSH and HTTPS passed installed; successful automatic reconnect after saved selection fix below |
| Bluetooth | Pair, audible A2DP audio to laptop, playback controls, reconnect and Forget passed RAM trials; bridge/server start on installed boot |
| Sleep | RAM trial: real suspend, Power wake, touch/radio/light restore; longest recorded suspend 5865.133 seconds |
| Shutdown | Patched-kernel RAM trial: LED and light off, then independent recovery entry without force reset |
| Installed sleep | Kernel reports 6.053-second actual suspend; owner confirms Power wake/touch; Wi-Fi, menu and frontlight restored |
| Installed shutdown | Owner confirms fully off/stays off; subsequent normal cold boot verified with automatic Wi-Fi and persistent SSH identity |
| Recovery | Re-entered after installed shutdown: authenticated USB SSH, RAM root, production storage unmounted and LK/U-Boot hashes preserved; return to Buildroot verified |
| Installer | Local staged transaction; 16 fault cases plus full device readback passed; no on-screen package picker yet |
| Browser/downloads | Standalone frontend/runtime not finished; menu entry alone does not establish a working browser |
| Playlists | Folder queue works; actual playlist management remains unfinished |

## Restart finding and fix

The first restart preserved the configuration and SSH identity, but the active
home network had been marked disabled in the saved configuration. Inspection
found that the menu's existing-saved-network selection path did not issue
SAVE_CONFIG, although adding a new network did save after connecting.

After enabling and saving the already-known network, a second normal restart
automatically completed WPA association and DHCP and accepted strictly pinned
Wi-Fi SSH, without a Wi-Fi service restart. The configuration and host-key
hashes matched their new baseline. This rules out claiming a required radio
startup workaround based only on the first empty scan list.

The menu source now saves existing-network selection and reports a save failure
separately. The rebuilt menu passed the existing connectivity regression checks and was
deployed with the prior binary retained for rollback. The successful second
reboot tested the saved state; physical selection through the updated UI still
needs a dedicated persistence check.

## What the battery observation means

An extended battery-powered sleep lasted about 1 hour 37 minutes. The owner
reported good battery behavior. The gauge read 100% before and immediately
after resume; USB was reconnected during follow-up. This is a coarse indicator,
not a measured zero-drain claim or a battery-life benchmark.

## Next work

1. Physically exercise saved-network selection in the updated menu.
2. Complete installed Bluetooth/audio regression; saved-light restart now passes.
3. Publish the remaining implementation source with dependencies and licenses.
4. Finish browser/downloads, playlists and recovery package Install/Update/Restore UI.

The overall project goal remains active and incomplete.

## Frontlight startup follow-up

The apparent black screen after cold boot was a zero frontlight level, not a
failed menu/display. The menu now saves actual brightness and logical warmth
with its existing UI settings, and the home startup restores those numeric
values. An explicit saved zero stays off; legacy files without the fields are
left unchanged. The new menu and helper are deployed with previous binaries
retained. Native save capture and restore parser tests passed. The owner then selected
brightness 10% and warmth 40%; a new normal restart restored those exact hardware
values automatically, with Wi-Fi and persistent SSH identity also passing.
Visual confirmation remains pending. Recovery still defaults to light off;
we enabled it at runtime for the re-entry check.
