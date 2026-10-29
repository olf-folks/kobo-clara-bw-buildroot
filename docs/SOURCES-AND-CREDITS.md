# Sources, credits and provenance

This project builds on substantial existing work. Links below identify the
actual role of each source; inclusion does not imply endorsement or personal
assistance. Pinned references are the revisions examined during investigation,
not a claim that those revisions are the latest releases.

## Boot-chain work that made the route possible

- **kos / koreader-os contributors**: the published software route for the
  related Clara Colour supplied the critical LK patch/digest method and
  unsigned U-Boot/kernel approach. We adapted it to BW after inspecting our
  own images. See the pinned
  [installer](https://github.com/koreader-os/installer/blob/616f152b3276e6751eb2a7ce3a4dfde82ff67a64/KoboRoot/usr/local/kos/install.sh),
  [LK patcher](https://github.com/koreader-os/installer/blob/616f152b3276e6751eb2a7ce3a4dfde82ff67a64/patch-lk/main.rs),
  [U-Boot configuration change](https://github.com/koreader-os/u-boot/commit/bdd69414357ce5dff357d48a33ebe64cbcfeeef6),
  [kernel builder](https://github.com/koreader-os/builder/blob/f7f99f2ea5454783b8ed6e048d607563b04555b5/linux/build.sh)
  and [initramfs installer](https://github.com/koreader-os/installer/blob/616f152b3276e6751eb2a7ce3a4dfde82ff67a64/initramfs/install.sh).
  Their installer has device-specific checks and formatting behavior; we did
  not use it unchanged on the BW. The
  [MobileRead announcement/discussion](https://www.mobileread.com/forums/showthread.php?p=4615120)
  supplied context and reported experience on another model.
- **enthdegree**: MediaTek/Kobo boot and boot0 documentation provided important
  early orientation. See
  [mt8113 at the examined revision](https://github.com/enthdegree/mt8113/tree/376724e3f856adf3be4e78ba851effc4f5d6b511),
  especially `documentation/boot.md`, `documentation/boot0.md` and normal-boot logs.
- **ratiz-glitch**: the
  [LK patch research](https://github.com/ratiz-glitch/mt8113/blob/693a4d019b2b056c6b2092fd61074d97d6307f82/patch-lk.py)
  and [mtkclient fork](https://github.com/ratiz-glitch/mtkclient/tree/e9169043893b06f4fd17d077e4688ff99cd54291)
  informed comparison of possible routes. Those patcher/client tools were
  inspected, not executed against this reader.
- **Kobo/Rakuten, Netronix, MediaTek and upstream contributors**: the
  [Kobo source distribution](https://github.com/kobolabs/Kobo-Reader/tree/7a762964e7fa71ad8e8df50dd1b6eee721a43217/hw)
  provided the vendor kernel/U-Boot and board-specific support. The BW source
  link at `hw/mt8113-claraBW_shine5BW` points into the shared MediaTek tree;
  board-specific DT selection remains necessary. This project is not a new
  implementation of those drivers.
- **Linux, U-Boot and Little Kernel contributors**: foundational boot/kernel
  software. See [Linux](https://www.kernel.org/),
  [U-Boot](https://docs.u-boot.org/) and
  [Little Kernel](https://github.com/littlekernel/lk).

## Native interface and stock-system integration

- **NiLuJe and FBInk contributors**: [FBInk](https://github.com/NiLuJe/FBInk)
  supplies the framebuffer/e-ink drawing foundation, panel quirks and rotation
  support used by the native interface. Its bundled dependencies retain their
  own notices; we do not claim to have written the low-level drawing library.
- **shermp and NickelDBus contributors**:
  [NickelDBus](https://github.com/shermp/NickelDBus) supplied stock integration
  during the initial launcher phase. Nickel is not the Buildroot desktop.
- **pgaskin and NickelHook/NickelMenu contributors**:
  [NickelHook](https://github.com/pgaskin/NickelHook) and
  [NickelMenu](https://github.com/pgaskin/NickelMenu) informed stock launcher/hook
  integration. Distinguish this earlier stock phase from the installed custom root.
- **KOReader contributors and Artifex/MuPDF contributors**:
  [KOReader](https://github.com/koreader/koreader) supplied the captured runtime
  used for the reader integration; [MuPDF](https://mupdf.com/) is the document
  rendering engine used by the native reader backend. Our UI is not a claim
  to have implemented an EPUB renderer from scratch.
- **i2c-tools, libunibreak, font and FBInk dependency authors**: supporting
  libraries remain upstream work. See
  [i2c-tools](https://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git/),
  [libunibreak](https://github.com/adah1972/libunibreak) and
  [DejaVu fonts](https://dejavu-fonts.github.io/).

## Userspace, networking, notes and audio

- [Buildroot](https://buildroot.org/) and its package maintainers: the rootfs
  build framework and package integration.
- [Arm GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads),
  [GCC](https://gcc.gnu.org/), [glibc](https://www.gnu.org/software/libc/),
  [BusyBox](https://busybox.net/) and [Zig](https://ziglang.org/): compiler,
  libc and development/runtime tooling used across the project phases.
- [libgit2](https://libgit2.org/), [libssh2](https://libssh2.org/) and
  [cJSON](https://github.com/DaveGamble/cJSON): manual Fieldnotes sync and data
  handling. The sync problem was not solved by adding Git CLI.
- [wpa_supplicant](https://w1.fi/wpa_supplicant/),
  [dhcpcd](https://github.com/NetworkConfiguration/dhcpcd),
  [Dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html) and
  [D-Bus](https://www.freedesktop.org/wiki/Software/dbus/): network and service
  infrastructure.
- [GStreamer](https://gstreamer.freedesktop.org/),
  [BlueZ](https://www.bluez.org/), [PipeWire](https://pipewire.org/) and
  [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/): audio and
  Bluetooth ecosystem. The laptop used BlueZ/PipeWire as the test sink; the
  Kobo retained a vendor Bluetooth stack and vendor audio plugin. This was not
  a complete BlueZ port to the Kobo.
- [Qt](https://www.qt.io/) and [WebKit](https://webkit.org/) contributors:
  retained vendor components and the planned standalone browser direction.
  A working vendor Qt service does not prove a completed browser port.

## Related work reviewed, not our tested installation route

[BandarLabs Cobalt](https://github.com/BandarLabs/Cobalt/blob/94f692078d7967a840872e422eb8bdf22bf5fe99/docs/DEVICES.md),
the [Nerves-on-Kobo account](https://elixirforum.com/t/the-journey-to-running-nerves-on-a-kobo-clara-e-reader/73331),
and [Quill](https://github.com/Quill-OS/quill) provided surrounding context.
Results on other readers are not direct proof of this N365B's behavior.

## Our contribution and evidence

The contribution recorded here is the BW-specific investigation, conservative
image preparation and preservation checks, independent recovery/menu,
Buildroot hardware integration, native application integration and on-device
regression work described in the journal. The owner performed the physical
screen, touch, cable, audio, sleep and shutdown checks. Development and writing
were AI-assisted. Upstream authors retain credit for their code and discoveries.

Private full-region hashes, logs and test results were used to write the status
record. Raw owner/device captures are intentionally not published. Claims about
our reader are our observations; upstream links support provenance, not a claim
that upstream projects validated our firmware. Please report missing or
incorrect credit so it can be corrected.
