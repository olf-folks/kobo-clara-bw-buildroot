# Buildroot integration notes

Buildroot integration v9 is installed and has booted from internal eMMC.
See the [current status](../docs/STATUS.md) and
[reproduction boundaries](../docs/REPRODUCING.md).

This public documentation/shell snapshot omits the complete external tree,
application bundle, patch generators and private hardware overlay. The retained
notes and scripts document the implementation; they are not a complete build.

The working target is ARM32 Cortex-A53 hard-float with a vendor 4.9.77 kernel,
Arm GCC 11.2 and glibc 2.34. Nickel is not a service in the installed image.
Vendor hardware components remain necessary. Notes, books and credentials
remain outside the public tree; Fieldnotes sync is manual only.
