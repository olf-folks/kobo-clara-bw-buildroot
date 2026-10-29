# Public snapshot boundaries

This repository was assembled from an active development workspace using an
explicit documentation/shell-script allowlist. It is not an upload of that
workspace or its history. The first public snapshot contains no full disk
images, vendor ELF files, books, notes, screenshots, raw device captures,
calibration, private manifests, Wi-Fi configuration, pairing databases,
SSH authorized_keys or public/private host/owner key files.

Private WLAN addresses, device MAC addresses and local account paths were
removed from the retained notes. The documented `192.168.77.1/30` and
`192.168.77.2/30` addresses are the intentional recovery USB protocol defaults,
not an owner's WLAN configuration. Firmware image hashes and paths such as
`/mnt/onboard/.adds/kobo-lab` are technical references, not credentials.

Some retained design/review notes describe earlier stages. They are archived
research context; [current status](STATUS.md) takes precedence. References in
those notes to Python/C/patch/build-output files do not mean those files are
included in this first publication. The selected shell scripts have been
syntax-checked, not rerun on the reader as part of publication.

## Why there is no downloadable firmware yet

The working image contains per-device inputs and vendor runtime components.
A release needs a reproducible source/dependency inventory, a clean local
provisioning process, license review for redistributed components, and remaining
installed-system regression checks. Publishing a personal working image would
not provide a clean, reusable release.

## Licensing

The original documentation and shell-script contributions in this repository
are offered under GPL-3.0-or-later; see [COPYING](../COPYING). Material derived
from upstream projects remains subject to its upstream terms. Links and credits
are not a relicensing of upstream code, firmware or media. No blanket license
is asserted over the excluded private working tree or vendor assets.

## Helping

Corrections to credit, replication reports with exact model/firmware/revision,
better build recipes, and narrowly scoped fixes are welcome. Remove network
credentials, keys, serials, notes, books and other personal data from issue
attachments. Distinguish tests actually performed from proposals.
