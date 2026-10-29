#!/bin/sh
# Owner-approved 2026-10-28 trial. No reboot, boot-variable, TEE or eFuse action.
set -eu
stage=/mnt/onboard/.adds/kobo-lab/boot-trial-20261028
ro=/sys/class/block/mmcblk0boot0/force_ro
dirty=0
success=0
hash() { sha256sum "$1" | cut -d ' ' -f 1; }
originals_match() {
    [ "$(hash /dev/mmcblk0boot0)" = e0e5f5a57ffd278801b68a2d1c5aeac3503495807ff40e592e3b800c1dcdf9f5 ] &&
    [ "$(hash /dev/mmcblk0p2)" = e41208956c50650fed45f5a3d59045d77eb1e2aeebcd021235ce6c65c7ebfa5e ] &&
    [ "$(hash /dev/mmcblk0p4)" = bb2d0a985a2c6a478b398313ee1581a1aceaa8f04baaf48b0aa255503561d59c ]
}
finish() {
    status=$?
    trap - EXIT HUP INT TERM
    set +e
    if [ "$dirty" = 1 ] && [ "$success" != 1 ]; then
        echo ROLLBACK_STARTED
        dd if="$stage/kernel-original.bin" of=/dev/mmcblk0p4 bs=4096
        dd if="$stage/uboot-original.bin" of=/dev/mmcblk0p2 bs=4096
        echo 0 > "$ro"
        dd if="$stage/boot0-original.bin" of=/dev/mmcblk0boot0 bs=4096
        echo 1 > "$ro"
        sync
        if originals_match; then echo ROLLBACK_VERIFIED; else echo ROLLBACK_FAILED_DO_NOT_REBOOT; status=3; fi
    fi
    echo 1 > "$ro"
    sync
    exit "$status"
}
trap finish EXIT
trap 'exit 1' HUP INT TERM
cd "$stage"
sha256sum -c INPUT-SHA256SUMS
for name in boot0 uboot kernel; do
    gzip -dc "$name-original.bin.gz" > "$name-original.bin.next"
    mv "$name-original.bin.next" "$name-original.bin"
done
[ "$(hash boot0-original.bin)" = e0e5f5a57ffd278801b68a2d1c5aeac3503495807ff40e592e3b800c1dcdf9f5 ]
[ "$(hash uboot-original.bin)" = e41208956c50650fed45f5a3d59045d77eb1e2aeebcd021235ce6c65c7ebfa5e ]
[ "$(hash kernel-original.bin)" = bb2d0a985a2c6a478b398313ee1581a1aceaa8f04baaf48b0aa255503561d59c ]
[ "$(hash boot0-candidate.bin)" = d4b77dd8f9eb57693fb2cd32b110f1ad459b622ae2038e4d79438265c34d19a1 ]
[ "$(hash uboot-candidate.itb)" = cfcd4e7924cde20f51c6324d9f028fa53474e0d5f63cef7604297881f7ab167b ]
[ "$(hash kernel-candidate.itb)" = 4081c5f22364bb8713537d8cb18d509e07bcb7b5d95aadc3526c766c0a664462 ]
for d in /dev/mmcblk0boot0 /dev/mmcblk0p2 /dev/mmcblk0p4; do [ -b "$d" ]; done
[ "$(cat /sys/class/block/mmcblk0boot0/size)" = 8192 ]
[ "$(cat /sys/class/block/mmcblk0p2/size)" = 2048 ]
[ "$(cat /sys/class/block/mmcblk0p4/size)" = 98304 ]
[ "$(cat "$ro")" = 1 ]
[ "$(cat /sys/class/power_supply/bd71827_bat/capacity)" -ge 30 ]
awk '$2=="/mnt/onboard" {found=1} END {exit !found}' /proc/mounts
originals_match
[ -z "$(pidof kobo-reader-engine || true)" ]
echo PREFLIGHT_VERIFIED
sync
dirty=1
echo 0 > "$ro"
dd if=boot0-candidate.bin of=/dev/mmcblk0boot0 bs=4096
echo 1 > "$ro"
sync
[ "$(hash /dev/mmcblk0boot0)" = d4b77dd8f9eb57693fb2cd32b110f1ad459b622ae2038e4d79438265c34d19a1 ]
echo STEP_LK_VERIFIED
dd if=uboot-candidate.itb of=/dev/mmcblk0p2 bs=4096
sync
[ "$(hash /dev/mmcblk0p2)" = 7dd9df4ded3ce65ce4a73115be98337b2f8295792142e30bcadbff627ce05b83 ]
echo STEP_UBOOT_VERIFIED
dd if=kernel-candidate.itb of=/dev/mmcblk0p4 bs=4096
sync
[ "$(hash /dev/mmcblk0p4)" = 90ce06d42274bbf27dc1e66e133f7926cfe93d1277eb1cafbcaff636b2cfc5ac ]
echo STEP_KERNEL_VERIFIED
sha256sum /dev/mmcblk0boot0 /dev/mmcblk0p2 /dev/mmcblk0p4
[ "$(cat "$ro")" = 1 ]
printf '%s\n' 'All three complete regions match the intended images; original tails preserved.' > WRITTEN-VERIFIED.txt
sync
success=1
echo WRITE_TRIAL_COMPLETE_NO_REBOOT_REQUESTED
