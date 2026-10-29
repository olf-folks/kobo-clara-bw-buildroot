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

## Current open issue

After normal restart, Wi-Fi settings and host identity persisted but automatic
association did not. A service restart restored scanning; enabling the existing
saved home-network entry restored association. We have not yet concluded how
much is initial firmware/radio startup versus saved selection state. See
[Status](STATUS.md) rather than treating this as a solved regression.
