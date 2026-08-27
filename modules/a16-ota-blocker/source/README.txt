A16 Samsung OTA Blocker v1.0
============================

Target device
-------------
Samsung Galaxy A16 5G SM-A166W
Tested firmware: A166WVLS8DZG1

What it blocks
--------------
- Samsung Software Update agent: com.sec.android.soagent
- Samsung FOTA download/management agent: com.wssyncmldm
- Android automatic OTA scheduling

What it does not block
----------------------
- Google Play Store app updates
- Galaxy Store app updates
- Google Play system updates
- Manual firmware flashing through Odin or recovery
- A factory reset, which erases the saved package state

Operation
---------
The block is applied during installation and checked every ten minutes while
KernelSU is active. Android's disabled-package state persists across ordinary
reboots even if KernelSU is not loaded.

KernelSU Action button
----------------------
Press Action once to temporarily enable Samsung firmware OTA. Press it again
to re-enable blocking. The module records its status in:

  /data/adb/a16_ota_blocker_state/status

Uninstallation
--------------
Uninstalling restores the package and setting states that existed before the
first installation. If either Samsung package was already disabled before the
module was installed, uninstalling intentionally leaves that package disabled.

To manually enable Samsung OTA after uninstalling, run as root:

  pm enable --user 0 com.sec.android.soagent
  pm enable --user 0 com.wssyncmldm
  settings put global ota_disable_automatic_update 0

Safety
------
This module does not replace system files, modify partitions, delete downloaded
firmware, change verified boot, or disable com.google.android.configupdater.
