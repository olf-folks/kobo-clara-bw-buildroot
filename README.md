# Kobo Clara BW: the road to Buildroot

We have booted a Kobo Clara BW **N365B** into a custom Buildroot userspace from
its internal eMMC, with a native touch menu, independent recovery, Wi-Fi/SSH,
reader, notes sync, Bluetooth audio, and tested power-management fixes.
This repository records the route, the upstream work it builds on, and the
remaining work so others can investigate and use their own readers.

This first public snapshot contains documentation and selected shell scripts.
It is **not a complete build tree or a ready-to-flash firmware release**.
The private working tree includes application C, recovery code, patches and
hardware inputs which are described here; those sources need a separate
publication pass. Linked paths to unpublished tools are identified in the guide.
No device image, credentials, keys, owner notes/books or device calibration is included.

## Start here

- [Current status and test boundaries](docs/STATUS.md)
- [What we did, in order](docs/JOURNEY.md)
- [Boot chain, partition map and recovery](docs/BOOT-AND-RECOVERY.md)
- [Build and installation workflow](docs/REPRODUCING.md)
- [Problems and fixes](docs/FIXES.md)
- [Sources and credits](docs/SOURCES-AND-CREDITS.md)
- [What was omitted from this public snapshot](docs/PUBLICATION.md)

Work was performed on firmware 4.46.23836, PCB 113 / E60T00, system-partition
type 25. Similar names and shared MediaTek source do not establish compatibility
with another Kobo model or revision. Bootloader writes can prevent normal boot;
keep verified originals and establish independent recovery before replacing the
system. The scripts are research/build examples, not an instruction to run all
of them against a reader.

The running kernel is still vendor **Linux 4.9.77, ARM32**. A future mainline or
AArch64 port is separate work. The system retains vendor hardware components;
it is not a fully free replacement of every firmware component.

The boot-unlock route owes a particular debt to
[kos / koreader-os](https://github.com/koreader-os/installer/blob/616f152b3276e6751eb2a7ce3a4dfde82ff67a64/patch-lk/main.rs).
Our framebuffer interface uses [NiLuJe's FBInk](https://github.com/NiLuJe/FBInk).
See the credits page for the wider set of upstream projects and the exact
roles of each; we do not claim those maintainers personally assisted or
endorsed this experiment.
