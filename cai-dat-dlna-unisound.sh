#!/bin/sh
VERSION="v3"

ADB_DEVICE_IP="192.168.43.1"
ADB_DEVICE_PORT="5555"
ADB_DEVICE="$ADB_DEVICE_IP:$ADB_DEVICE_PORT"
RECONNECT_COUNT=0
MAX_RECONNECT=999
ADB="adb"

DLNA_APK_NAME="auto-dlna.apk"
DLNA_APK_LOCAL_PATH="$HOME/$DLNA_APK_NAME"
DLNA_APK_REMOTE_PATH="/data/local/tmp/$DLNA_APK_NAME"

UNISOUND_APK_NAME="uni-sound.apk"
UNISOUND_APK_LOCAL_PATH="$HOME/$UNISOUND_APK_NAME"
UNISOUND_APK_REMOTE_PATH="/data/local/tmp/$UNISOUND_APK_NAME"

log_info() {
    echo "[aibox+$VERSION] $*"
}

fail() {
    log_info "$1"
    exit 1
}

check_adb() {
    log_info "Kiem tra adb..."
    if ! command -v adb >/dev/null 2>&1; then
        log_info "adb chua duoc cai. Dang cai dat android-tools..."
        if command -v apk >/dev/null 2>&1; then
            apk add --no-cache android-tools
        elif command -v pkg >/dev/null 2>&1; then
            pkg install -y android-tools
        else
            fail "Khong tim thay trinh quan ly goi phu hop de cai dat adb. Vui long cai dat adb thu cong."
        fi
    fi
}

wait_for_wifi() {
    log_info "Kiem tra ket noi Wi-Fi toi $ADB_DEVICE_IP..."
    local wifi_prompt_shown=0
    while true; do
        if ping -c 1 -W 1 "$ADB_DEVICE_IP" >/dev/null 2>&1; then
            log_info "Da ping thanh cong $ADB_DEVICE_IP."
            return
        fi
        if [ "$wifi_prompt_shown" -eq 0 ]; then
            log_info "Hay ket noi toi Wifi cua loa: Phicomm R1"
            wifi_prompt_shown=1
        fi
        sleep 3
    done
}

is_device_connected() {
    "$ADB" devices 2>/dev/null | awk -v dev="$ADB_DEVICE" '$1==dev && $2=="device" {found=1} END {exit (found?0:1)}'
}

ensure_device_connection() {
    wait_for_wifi
    if is_device_connected; then
        return
    fi
    connect_adb
}

adb_exec() {
    "$ADB" "$@"
}

reconnect_adb() {
    while true; do
        RECONNECT_COUNT=$((RECONNECT_COUNT + 1))
        if [ "$RECONNECT_COUNT" -gt "$MAX_RECONNECT" ]; then
            fail "Khong the ket noi ADB sau $MAX_RECONNECT lan thu."
        fi

        log_info "Mat ket noi ADB, thu ket noi lai (lan $RECONNECT_COUNT)..."
        wait_for_wifi
        "$ADB" connect "$ADB_DEVICE" >/dev/null 2>&1 || true
        sleep 2

        if is_device_connected; then
            RECONNECT_COUNT=0
            return
        fi
    done
}

connect_adb() {
    log_info "Khoi dong lai ket noi ADB..."
    wait_for_wifi
    while true; do
        "$ADB" disconnect
        "$ADB" kill-server
        "$ADB" connect "$ADB_DEVICE"
        if is_device_connected; then
            return
        fi
        log_info "Chua ket noi duoc $ADB_DEVICE, thu lai..."
        sleep 2
    done
}

step_push_apk() {
    local apk_path="$1"
    local apk_remote_path="$2"
    adb_exec push "$apk_path" "$apk_remote_path"
}

step_install_apk() {
    local name="$1"
    local path="$2"
    log_info "Cai dat $name..."
    adb_exec shell /system/bin/pm install -r "$path"
}

step_reboot_device() {
    log_info "Khoi dong lai thiet bi..."
    adb_exec reboot &
}

allow_install_non_market_apps() {
    adb_exec shell settings put secure install_non_market_apps 1
}

check_adb
connect_adb

allow_install_non_market_apps

step_push_apk "$DLNA_APK_LOCAL_PATH" "$DLNA_APK_REMOTE_PATH"
step_install_apk "$DLNA_APK_NAME" "$DLNA_APK_REMOTE_PATH"

step_push_apk "$UNISOUND_APK_LOCAL_PATH" "$UNISOUND_APK_REMOTE_PATH"
step_install_apk "$UNISOUND_APK_NAME" "$UNISOUND_APK_REMOTE_PATH"

step_reboot_device
