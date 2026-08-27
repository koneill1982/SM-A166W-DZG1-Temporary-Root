#!/system/bin/sh

STATE_DIR=${A16_OTA_STATE_DIR:-/data/adb/a16_ota_blocker_state}
ANDROID_BIN=${ANDROID_BIN:-/system/bin}
LOG_FILE="$STATE_DIR/ota-blocker.log"
TARGET_PACKAGES="com.sec.android.soagent com.wssyncmldm"

write_log() {
    mkdir -p "$STATE_DIR"
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

package_exists() {
    "$ANDROID_BIN/pm" path "$1" >/dev/null 2>&1
}

package_is_disabled() {
    "$ANDROID_BIN/pm" list packages -d --user 0 2>/dev/null |
        grep -qx "package:$1"
}

capture_setting() {
    namespace="$1"
    setting_name="$2"
    state_name="$3"
    setting_value="$("$ANDROID_BIN/settings" get "$namespace" "$setting_name" 2>/dev/null)"
    [ "$setting_value" = "null" ] && setting_value="__ABSENT__"
    printf '%s\n' "$setting_value" > "$STATE_DIR/$state_name"
}

restore_setting() {
    namespace="$1"
    setting_name="$2"
    state_name="$3"
    [ -f "$STATE_DIR/$state_name" ] || return 0
    setting_value="$(sed -n '1p' "$STATE_DIR/$state_name")"
    if [ "$setting_value" = "__ABSENT__" ]; then
        "$ANDROID_BIN/settings" delete "$namespace" "$setting_name" >/dev/null 2>&1
    else
        "$ANDROID_BIN/settings" put "$namespace" "$setting_name" "$setting_value" >/dev/null 2>&1
    fi
}

capture_initial_state() {
    mkdir -p "$STATE_DIR"
    chmod 0700 "$STATE_DIR"
    [ -f "$STATE_DIR/initialized" ] && return 0

    for package_name in $TARGET_PACKAGES; do
        state_file="$STATE_DIR/package_${package_name}"
        if ! package_exists "$package_name"; then
            printf '%s\n' "absent" > "$state_file"
        elif package_is_disabled "$package_name"; then
            printf '%s\n' "disabled" > "$state_file"
        else
            printf '%s\n' "enabled" > "$state_file"
        fi
    done

    capture_setting global ota_disable_automatic_update setting_ota_disable_automatic_update
    touch "$STATE_DIR/initialized"
    write_log "Captured pre-install state"
}

block_updates() {
    mkdir -p "$STATE_DIR"
    chmod 0700 "$STATE_DIR"

    for package_name in $TARGET_PACKAGES; do
        if package_exists "$package_name"; then
            if ! package_is_disabled "$package_name"; then
                "$ANDROID_BIN/pm" disable-user --user 0 "$package_name" >/dev/null 2>&1
                write_log "Disabled $package_name"
            fi
            "$ANDROID_BIN/am" force-stop --user 0 "$package_name" >/dev/null 2>&1
        fi
    done

    current_ota_setting="$("$ANDROID_BIN/settings" get global ota_disable_automatic_update 2>/dev/null)"
    if [ "$current_ota_setting" != "1" ]; then
        "$ANDROID_BIN/settings" put global ota_disable_automatic_update 1 >/dev/null 2>&1
        write_log "Disabled automatic OTA scheduling"
    fi

    printf '%s\n' "blocked" > "$STATE_DIR/status"
}

allow_updates_temporarily() {
    mkdir -p "$STATE_DIR"
    touch "$STATE_DIR/paused"

    for package_name in $TARGET_PACKAGES; do
        if package_exists "$package_name"; then
            "$ANDROID_BIN/pm" enable --user 0 "$package_name" >/dev/null 2>&1
            write_log "Temporarily enabled $package_name"
        fi
    done

    restore_setting global ota_disable_automatic_update setting_ota_disable_automatic_update
    printf '%s\n' "paused" > "$STATE_DIR/status"
}

restore_initial_state() {
    for package_name in $TARGET_PACKAGES; do
        state_file="$STATE_DIR/package_${package_name}"
        [ -f "$state_file" ] || continue
        original_state="$(sed -n '1p' "$state_file")"
        case "$original_state" in
            enabled)
                "$ANDROID_BIN/pm" enable --user 0 "$package_name" >/dev/null 2>&1
                ;;
            disabled)
                "$ANDROID_BIN/pm" disable-user --user 0 "$package_name" >/dev/null 2>&1
                ;;
        esac
    done

    restore_setting global ota_disable_automatic_update setting_ota_disable_automatic_update
}
