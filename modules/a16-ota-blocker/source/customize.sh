#!/system/bin/sh

ui_print "***************************************"
ui_print " A16 Samsung OTA Blocker v1.0"
ui_print "***************************************"

device_model="$(getprop ro.product.model)"
device_build="$(getprop ro.build.version.incremental)"

if [ "$device_model" != "SM-A166W" ]; then
    abort "This module is only for SM-A166W. Detected: $device_model"
fi

if [ "$KSU" != "true" ]; then
    abort "Install this ZIP through KernelSU Manager."
fi

ui_print "- Device: $device_model"
ui_print "- Build:  $device_build"
ui_print "- Saving the current update configuration"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/customize.sh" 0 0 0755
set_perm "$MODPATH/ota-control.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

MODDIR="$MODPATH"
. "$MODPATH/ota-control.sh"

capture_initial_state
rm -f "$STATE_DIR/paused"
block_updates

ui_print "- Disabled com.sec.android.soagent"
ui_print "- Disabled com.wssyncmldm"
ui_print "- Disabled automatic OTA scheduling"
ui_print "- Samsung firmware OTA is now blocked"
ui_print "- The Action button temporarily allows OTA"
ui_print "- No reboot is required for the initial block"

