# Problems and fixes from device testing

These are observations of our vendor 4.9.77 system. The implementation source
and patch publication is pending beyond the shell examples in this snapshot.

| Problem | Diagnosis / change | Evidence |
|---|---|---|
| DHCP process failed | New ARM libc time64 probe syscalls hit dhcpcd's sandbox built against older headers; account for the required probes | Actual WPA, DHCP, SSH and HTTPS succeeded |
| Fieldnotes sync failed | libgit2 directory iterator iconv handle needed initialization to `(iconv_t)-1`; Git CLI was not the dependency | Manual sync succeeded after libgit2 patch |
| Warmth reversed | Hardware value and UI percentage had opposite meanings; invert both read and write mappings | Owner confirmed 100% now means warmer |
| Hardware modules unavailable | WMT opens module paths with `O_NOFOLLOW`; use regular files at required paths | Hardware ready and radio startup passed |
| WMT loader status misleading | Vendor loader can return 255 after successful insertion; allow 0/255 only with independent module/node/process checks | Hardware startup passed actual trials |
| Bluetooth UI failed on new rootfs | Start vendor bridge/server with correct isolated Qt/runtime paths and usable D-Bus tooling | Pair/connect/scan succeeded |
| Bluetooth connected without audible audio | Missing vendor GStreamer A2DP plugin / compatible dependencies | Owner heard laptop-sink audio and tested controls |
| Disconnect appeared ineffective | Trace showed correct Disconnect call; completion was delayed | Both endpoints and owner eventually confirmed disconnect |
| Missing Forget action | Add confirmation and Adapter1.RemoveDevice; retain selection on failure | Backend checks and owner removal test passed |
| Shutdown went black but did not power off reliably | PMIC I2C in final `pm_power_off` could wait for IRQs after interrupts were disabled; perform existing PMIC operation in `pm_power_off_prepare` | Lights/LED off followed by ordinary recovery entry without forced reset |
| Sleep immediately returned | Panel power/XON settling still pending; then radio wake source remained active | Seven-second settling and quiesced radios produced actual suspend |

The sleep helper records previous Wi-Fi/Bluetooth/frontlight states, quiesces
radios, turns the light off, syncs and waits seven seconds before requesting
`mem`. It restores the previous states after return. The panel timing observed
in source included roughly 4.35-second daytime XON behavior; two seconds was
insufficient. We did not change the panel's waveform timings or blindly mask
wake interrupts. An installed-system sleep regression remains to be done.

A black e-ink screen alone does not prove poweroff, nor does a blank/unchanged
panel prove a failed kernel boot. Use USB, process/kernel evidence, LEDs and
subsequent boot/recovery behavior together.

## Restart / saved-network selection

The first restart preserved the config file, but the home profile remained
disabled in it: selecting an existing saved profile had changed runtime state
without saving the selection. Enabling and saving that profile restored
automatic WPA/DHCP and pinned SSH after another normal reboot, without a Wi-Fi
service restart. The menu source now saves existing-network selection and
reports persistence failure. The rebuilt menu is deployed; existing connectivity
regression tests passed. Physical selection persistence testing remains.

## Frontlight persistence

A normal cold boot left the native menu running with brightness zero. We now
save actual brightness and logical warmth alongside UI font settings. The home
session restores them on startup using a parser that accepts only bounded
canonical decimal values; it never sources the settings file as shell code.
The helper preserves explicitly saved off/zero and leaves legacy settings
without light fields unchanged. Native save capture and parser tests pass;
deployment is complete, with a physical setting/restart check pending.

The shell examples are [restore-light.sh](../cfw/board/restore-light.sh) and
[kobo-home.sh](../cfw/board/kobo-home.sh). Their installed paths are
`/usr/lib/kobo-lab/restore-light` and `/usr/bin/kobo-home`. They require the
corresponding updated native menu to write the new settings fields.
