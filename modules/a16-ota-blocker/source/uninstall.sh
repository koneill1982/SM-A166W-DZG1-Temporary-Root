#!/system/bin/sh

MODDIR=${0%/*}
. "$MODDIR/ota-control.sh"

if [ -f "$STATE_DIR/watchdog.pid" ]; then
    watchdog_pid="$(sed -n '1p' "$STATE_DIR/watchdog.pid")"
    [ -n "$watchdog_pid" ] && kill "$watchdog_pid" >/dev/null 2>&1
fi

restore_initial_state
rm -rf "$STATE_DIR"
