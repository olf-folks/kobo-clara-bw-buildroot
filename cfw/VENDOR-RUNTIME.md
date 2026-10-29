> Historical implementation notes. For current installed-system status and public source availability, see [Status](../docs/STATUS.md). Referenced implementation files may be absent from this documentation/shell snapshot.

# Vendor runtime audit — 2026-10-28

The first custom vendor 4.9.77 kernel boots and exposes root SSH over Wi-Fi.
The four captured radio modules are loaded. Buildroot remains a separate,
unfinished userspace image; none of its files have replaced the running root.

`research/boot-chain/2026-10-27/audit-vendor-runtime.py` reads the existing
stock-root image using debugfs without `-w`. It extracts only selected software
and its direct ELF dependency closure, without mounting the image, running
ARM binaries, or reading personal configuration. Input image is the previously
captured p10, SHA256
43e5746d347ea85c6b448988db292a67668ec7a2d40434c2791856f533887675.

Run from the project root:

```sh
python3 research/boot-chain/2026-10-27/audit-vendor-runtime.py \
  ~/.local/state/kobo-boot-investigation/20261027/recovery-analysis/system-for-analysis.img \
  ~/.local/state/kobo-boot-investigation/20261027/vendor-runtime-audit
```

Seeds are mdpd, nvram_daemon, wmt_loader, wmt_launcher, mtkbtd,
Qt5WebKitWidgets and the Kobo Qt platform plugin. The recorded closure has
41 unique ELF files, 54,665,764 bytes, and no unresolved DT_NEEDED entries.
Hashes, paths, required ABI version names and dependency lists are in the
private `vendor-runtime-audit/dependency-report.json` beside extracted files.

The Qt5 library names resolve through symlinks into the legacy-named
`/usr/local/Trolltech/QtEmbedded-4.6.2-arm/lib/` directory. Directory and file
names alone must not be used to infer the actual Qt version. Some of these
links exceed the inline-symlink size and require reading the link inode data.

Neither WebKit, WebKitWidgets nor the Kobo Qt platform plugin declares a
DT_NEEDED dependency on libnickel. No undefined dynamic symbol in these three
libraries contains `nickel`, `kobo`, `ntx` or `hwtcon`. This supports building
a standalone frontend, but does not prove runtime independence: dlopen,
Qt plugin initialization, hardware access, resources and process environment
remain untested. The existing browser probe's old JavaScript limitations still
apply. No Xorg is required by the proposed use of the Kobo platform plugin.

Do not copy the entire closure into Buildroot's library search path: the audit
includes stock libc, loader and C++ runtime for completeness. Buildroot must
supply its own coherent libc/loader, and each retained vendor object needs ABI
and symbol checks against that runtime. A vendor library directory can carry
non-base dependencies and preserve SONAME aliases only after those checks.

Next integration work:

- Preserve board calibration/NVRAM and firmware path expectations without
  copying passwords, notes or SSH private keys into build sources.
- Establish mdpd/display initialization and WMT/radio daemon startup order.
- Inspect dlopen/plugin dependencies and Qt resources separately.
- Prove a standalone Qt application can initialize the platform and render
  with Nickel absent before claiming a browser works.
- Buildroot hardware init currently fails explicitly when the required vendor
  startup helper is absent. Keep that failure until integration is complete.

## Buildroot integration checks — resumed goal

Fresh live mdpd mappings include libmdp.mt8512.so, libmdppq.so and
libmdp_prot.mt8512.so. Added explicit --seed support to the read-only vendor
audit so runtime-loaded platform libraries can be audited too. The expanded
private dependency report has 19 ELF files. Static strong-symbol/DT_NEEDED
checks pass for four hardware programs and those three libraries against the
existing Buildroot runtime. cfw/tools/stage-hardware-runtime.py stages 11
selected vendor objects; stock base runtime libraries remain excluded.

cfw/tools/stage-board-assets.py reads the pinned stock-root image read-only,
extracts only seven selected MTK firmware files, and checks module vermagic
and all imported CRCs against kernel and companion-module exports before
staging four modules. All 584 imports pass. These checks do not prove hardware
startup or calibration correctness. Staging directories are private under
~/.local/state/kobo-boot-investigation/20261027/:

- vendor-hardware-expanded-audit: selected source ELF dependency closure.
- buildroot-hardware-v2: 11 audited runtime ELF objects.
- buildroot-board-assets-v1: firmware/modules and checked manifest.
- buildroot-device-state-v1: live /data/nvram archive captured privately (11
  entries), with no Wi-Fi configuration or owner keys included.

On-device no-device chroot smoke test passes using Buildroot's own loader,
libc and BusyBox: four hardware program loader checks, three platform-library
loader checks, native menu loading and --self-test. No /dev, /proc or /sys was
mounted into the chroot; no vendor daemon was launched. Original smoke bundle
omitted BusyBox's libresolv dependency and failed before the loader checks;
the packager now follows the smoke applications' own dependency closure.
The corrected v2 test exits zero and removes its temporary package/directory.
Evidence: build/buildroot-20261028/on-device-hardware-smoke-v2.txt.
Stock custom menu stayed awake throughout (menu_awake=1 idle_seconds=0).

The test packager supplies /usr/lib aliases for vendor platform libraries
because libmdpd explicitly looks there; production staging must retain those
aliases. wmt_loader also embeds /drivers/mt8113t-ntx/mt66xx, so production
radio startup must either preserve that path or load verified modules
explicitly in the correct order. /dev/disk/by-partlabel/nvram maps to p3 on
stock; mdev needs an equivalent verified mapping. nvram_daemon exits after
startup on stock, so its absence in a later process listing is expected and
must not be diagnosed as a daemon crash without logs.

Remaining: hardware startup ordering/health checks, private calibration and
owner provisioning integration, Wi-Fi/SSH lifecycle, framebuffer/touch use
under the actual Buildroot init, then a coordinated userspace boot trial.
Independent recovery remains installed and unchanged.
