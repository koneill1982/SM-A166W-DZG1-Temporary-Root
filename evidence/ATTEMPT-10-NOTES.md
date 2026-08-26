# SM-A166W DZG1 Attempt 10

## Status

Built, audited, and run exactly once on 2026-08-26. **Successful.** The phone
did not panic or reboot. The payload exited normally with status 0, and no
second execution was made.

## Run result

- Exact-build preflight passed.
- KASLR slide recovered as `0x8000`.
- Full controlled 32-object `mm_struct` group found after 61 attempts.
- MCAST writer used the corrected `0x98` offset and returned the expected
  `EADDRNOTAVAIL` (`errno=99`) with the scheduling window verified.
- Controlled physical read/write proof passed, including restoration checks.
- Root helper completed successfully: `uid 2000 -> 0`.
- A separate root-client check returned:
  `uid=0(root) gid=0(root) context=u:r:kernel:s0`.
- SELinux is Permissive for the current boot.
- Verified boot remains green, vbmeta remains locked, and warranty bit remains
  0.

This root session is currently boot-volatile. Rebooting is expected to remove
the active root service and return SELinux to its normal boot policy.

## Single functional change from Attempt 9

`MCAST_WAITER_OFF` changed from `0x48` to `0x98`.

The Attempt 9 Samsung panic dump showed the complete forged waiter at
`ffffffc020693b18`, while the stale `rt_mutex_waiter` pointer was
`ffffffc020693b68`. The stale pointer is exactly `0x50` bytes after the forged
waiter start, so the hardware-calibrated placement is `0x48 + 0x50 = 0x98`.
The exact DZG1 waiter is `0x58` bytes, and still fits within the MCAST copy:
`0x98 + 0x58 = 0xf0 <= 0x108`.

## Preserved safeguards

- Exact firmware fingerprint required:
  `samsung/a16xcs/a16x:16/BP4A.251205.006/A166WVLS8DZG1:user/release-keys`
- Absolute exploit-attempt cap: 1
- MCAST stack writer only
- SIGRETURN and pselect writers disabled for this target
- Trace-marker KASLR recovery
- Controlled full `mm_struct` group and shaped `0x8e80` SKB reclaim
- Samsung-inaccessible kmem trace-event gate remains disabled

## Binary audit

The compiled ARM64 app contains:

```text
mov w1, #0x98        ; put_fake_waiter offset
bl  put_fake_waiter
mov w4, #0x108       ; setsockopt copy length
bl  setsockopt
```

The build label is:

```text
a16x-SM-A166W-DZG1-attempt10-hwcal-mcast98
```

No `sigreturn` marker is present in the compiled app.

## Locations

- Source: `../../source/ghostlock-sm-a166w-attempt10`
- Binaries: `build/`
- Checksums: `SHA256SUMS`
- Durable run log: `a16x-attempt10-hwcal-mcast98.log`
- Complete live transcript: `a16x-attempt10-live.log`
