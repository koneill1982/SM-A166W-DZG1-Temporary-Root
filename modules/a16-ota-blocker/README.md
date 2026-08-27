# A16 Samsung OTA Blocker — KernelSU module

Optional companion module for a rooted Samsung Galaxy A16 5G SM-A166W. This
module is intended for users who want to remain on the firmware they are
currently running. Version 1.0 was tested against `A166WVLS8DZG1`.

## Download

- [A16-Samsung-OTA-Blocker-v1.0.zip](A16-Samsung-OTA-Blocker-v1.0.zip)
- Verify it with [SHA256SUMS.txt](SHA256SUMS.txt) before installation.

## What it blocks

- Samsung Software Update agent: `com.sec.android.soagent`
- Samsung FOTA download/management agent: `com.wssyncmldm`
- Android automatic OTA scheduling through
  `global/ota_disable_automatic_update`

The module applies the block during installation. While KernelSU is active,
its watchdog checks the state every ten minutes. Android's disabled-package
state persists across ordinary reboots even when KernelSU is not loaded.

## What it does not block

- Google Play Store app updates
- Galaxy Store app updates
- Google Play system updates
- `com.google.android.configupdater`
- Manual firmware flashing through Odin or recovery
- A factory reset

This is not an absolute anti-update mechanism. Manual flashing, recovery work,
or a factory reset can bypass or remove its protection.

## Install

1. Download the ZIP without extracting it.
2. Open KernelSU Manager.
3. Open **Modules**, press **+**, and select the ZIP.
4. Confirm that installation reports all three OTA controls as disabled.

The initial block is applied immediately. A reboot is not required. The
watchdog starts whenever KernelSU services next start.

## Verify

Run from a root shell:

```sh
pm list packages -d | grep -E 'com.sec.android.soagent|com.wssyncmldm'
settings get global ota_disable_automatic_update
```

Both Samsung packages should be listed and the setting should return `1`.

## Temporarily allow Samsung OTA

Press the module's **Action** button once to pause blocking and enable the two
Samsung OTA packages. Press **Action** again to restore blocking.

## Uninstall

Uninstalling restores the package and setting states captured before the first
installation. If a package was already disabled before installation, it is
left disabled when the module is removed.

## Source

The complete module source is in [`source/`](source/). The module modifies no
system partition and replaces no system file.
