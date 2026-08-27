#!/system/bin/sh

MODDIR=${0%/*}
. "$MODDIR/ota-control.sh"

capture_initial_state

if [ -f "$STATE_DIR/paused" ]; then
    rm -f "$STATE_DIR/paused"
    block_updates
    /system/bin/sh "$MODDIR/service.sh" >/dev/null 2>&1 &
    echo "Samsung firmware OTA blocking is ON"
else
    allow_updates_temporarily
    if [ -f "$STATE_DIR/watchdog.pid" ]; then
        watchdog_pid="$(sed -n '1p' "$STATE_DIR/watchdog.pid")"
        [ -n "$watchdog_pid" ] && kill "$watchdog_pid" >/dev/null 2>&1
        rm -f "$STATE_DIR/watchdog.pid"
    fi
    echo "Samsung firmware OTA blocking is PAUSED"
    echo "Use the Action button again to turn blocking back on"
fi
