#!/system/bin/sh

MODDIR=${0%/*}
. "$MODDIR/ota-control.sh"

[ -f "$STATE_DIR/paused" ] && exit 0

mkdir -p "$STATE_DIR"
pid_file="$STATE_DIR/watchdog.pid"

if [ -f "$pid_file" ]; then
    old_pid="$(sed -n '1p' "$pid_file")"
    if [ -n "$old_pid" ] && kill -0 "$old_pid" >/dev/null 2>&1 &&
        [ -r "/proc/$old_pid/cmdline" ]; then
        old_command="$(tr '\000' ' ' < "/proc/$old_pid/cmdline")"
        case "$old_command" in
            *"$MODDIR/service.sh"*) exit 0 ;;
        esac
    fi
    rm -f "$pid_file"
fi

printf '%s\n' "$$" > "$pid_file"
trap 'rm -f "$pid_file"' EXIT INT TERM

boot_wait=0
while [ "$boot_wait" -lt 30 ]; do
    "$ANDROID_BIN/pm" list packages --user 0 >/dev/null 2>&1 && break
    boot_wait=$((boot_wait + 1))
    sleep 2
done

block_updates

while [ -d "$MODDIR" ] && [ ! -f "$STATE_DIR/paused" ]; do
    sleep 600
    [ -f "$STATE_DIR/paused" ] && break
    block_updates
done
