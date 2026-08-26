# Samsung SM-A166W DZG1 temporary KernelSU root

Device-tested release for one exact Samsung Galaxy A16 5G firmware. This is
not a generic Galaxy A16 package.

## Exact supported build

- Model: `SM-A166W`
- Device: `a16x`
- Firmware: `A166WVLS8DZG1`
- Build fingerprint: `samsung/a16xcs/a16x:16/BP4A.251205.006/A166WVLS8DZG1:user/release-keys`
- Security patch: `2026-07-05`
- Kernel: `5.15.189-android13-3-33503169`
- Page size: `4096`
- Architecture: `aarch64`

Do not use these binaries on another model, firmware, kernel release, or page
size. The offsets are firmware-specific. A mismatch can panic the kernel,
reboot the phone, corrupt data, or leave the device unable to boot.

## What was tested

The exploit and KernelSU late-load chain were tested on physical SM-A166W
hardware on 2026-08-26:

1. The exact-build preflight passed.
2. Attempt 10 completed once with status 0 and changed the root helper from
   shell UID 2000 to UID 0.
3. The matching KernelSU v3.2.5 module was late-loaded.
4. `/proc/modules` reported `kernelsu` live.
5. The official KernelSU Manager v3.2.5 detected KernelSU and could manage app
   root permissions.
6. SELinux was returned to Enforcing after KernelSU late-load.

No boot, init_boot, vendor_boot, recovery, vbmeta, or other partition was
flashed. Root is temporary: rebooting removes the loaded module and the
exploit/late-load sequence must be run again.

## Files

### `binaries/`

- `cve-2026-43499-app-SM-A166W-DZG1-attempt10.so`: exact successful app-domain
  payload.
- `cve-2026-43499-root-SM-A166W-DZG1-attempt10`: root helper and payload
  supervisor.
- `cve-2026-43499-SM-A166W-DZG1-attempt10`: matching preload build retained for
  auditing and development.

### `kernelsu/`

- `ksud-SM-A166W-DZG1-v3.2.5`: matching kallsyms-aware late loader. It embeds
  the tested module and includes compatibility for the helper's `--ephemeral`
  argument.
- `SM-A166W_DZG1_KernelSU_v3.2.5.ko`: release module embedded in the loader.
- `SM-A166W_DZG1_KernelSU_v3.2.5_debug.ko`: unstripped audit/debug build.
- `KernelSU_v3.2.5_32525-release.apk`: official KernelSU Manager APK.

The standalone `.ko` cannot be loaded with ordinary `insmod`. It lacks usable
symbol-version entries for the device and requires this matching, kallsyms-
aware `ksud` build. Do not mix the module or loader with another release.

### `sources/`

- Exact Attempt-10 exploit source snapshot.
- Modified KernelSU v3.2.5 source snapshot based on upstream commit
  `b0bc817b4e966aa6aa830834eaf6ef765d821d40`.
- Samsung open-source archives used for kernel reference and headers.
- Reproduction metadata and audit records.

### `evidence/`

- Durable successful-run log.
- Complete successful live transcript.
- Attempt-10 notes and original checksums.

## Running it

Install Android platform tools, enable USB debugging, authorize the computer,
and make a backup first. From this release directory run:

```sh
./run-on-exact-firmware.sh
```

The launcher verifies the release-file hashes and checks the connected phone's
model, fingerprint, kernel release, and page size before it offers to proceed.
It caps the exploit at one attempt.

After a successful run, open KernelSU Manager and grant root only to apps you
trust. Re-run the launcher after every reboot if temporary root is still
wanted.

## Verification

```sh
sha256sum --check SHA256SUMS.txt
```

## Source and licenses

- Root My Galaxy payload base: <https://github.com/Meowkis/Root-My-Galaxy-Payloads>
- CVE-2026-43499 exploit lineage: <https://github.com/NebuSec/CyberMeowfia/tree/main/IonStack/CVE-2026-43499/exploit>
- KernelSU v3.2.5: <https://github.com/tiann/KernelSU/tree/v3.2.5>
- Samsung Open Source: <https://opensource.samsung.com/>

The exploit payload source is distributed under Apache-2.0. KernelSU and the
modified KernelSU source are distributed under GPL-3.0. Samsung/Linux kernel
source retains its upstream and Samsung licensing. See `LICENSES/` and the
license files inside each source archive.

This release is provided without warranty. Use it only on a device you own or
are explicitly authorized to test.
