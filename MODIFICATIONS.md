# Modification and provenance record

## Exploit payload

The SM-A166W DZG1 payload is a firmware-specific modification of
`Meowkis/Root-My-Galaxy-Payloads` at commit
`5d2b797276498827faa71519ebaf35f41bca2e5a`.

The port adds the `a16x-SM-A166W-DZG1` target and changes the exploit flow for
the Samsung 5.15 kernel on firmware A166WVLS8DZG1. The device-tested Attempt-10
variant uses a controlled `mm_struct` group, shaped order-3 SKB reclaim,
trace-marker KASLR recovery, and the hardware-calibrated MCAST waiter copy
offset `0x98`. It enforces the exact build fingerprint and a one-attempt cap.

`patches/Root-My-Galaxy-Payloads-SM-A166W-DZG1-attempt10.patch` records the
source differences from that upstream commit. The complete resulting source is
under `exploit/`.

## KernelSU

The KernelSU work is based on official KernelSU tag `v3.2.5`, commit
`b0bc817b4e966aa6aa830834eaf6ef765d821d40`.

The changes add Samsung KDP/DEFEX compatibility, Samsung 5.15 syscall-hook
handling, late-load adjustments, and compatibility with the guarded GhostLock
helper's `--ephemeral` argument. The `ksud` asset set embeds the exact
SM-A166W DZG1 module.

`patches/KernelSU-v3.2.5-SM-A166W-DZG1.patch` records the source differences
from the official tag. The complete resulting source is under
`kernelsu-modified/`.

## Build inputs

- Android NDK r27d was used for the ARM64 userspace payload and final `ksud`.
- The module vermagic is
  `5.15.189-android13-3-33503169 SMP preempt mod_unload modversions aarch64`.
- Samsung's SM-A166B Android 16 open-source kernel archive and SM-A166W DTS
  archive were used as kernel reference material.
- Runtime headers, configuration, BTF, build logs, and audit records are in the
  `SM-A166W-DZG1-build-metadata.tar.xz` release asset.

All modified builds are supplied without warranty and are limited to the exact
firmware documented in the main README.
