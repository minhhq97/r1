#!/bin/sh
DOMAIN="https://loaphicomr1.click"

VERSION="v3"
APK_NAME="ai-box-plus-$VERSION.apk"
APK_URL="$DOMAIN/$VERSION/$APK_NAME"
APK_PATH="$HOME/$APK_NAME"

DLNA_APK_NAME="auto-dlna.apk"
DLNA_APK_LOCAL_PATH="$HOME/$DLNA_APK_NAME"
DLNA_APK_URL="$DOMAIN/$VERSION/$DLNA_APK_NAME"

UNISOUND_APK_NAME="uni-sound.apk"
UNISOUND_APK_LOCAL_PATH="$HOME/$UNISOUND_APK_NAME"
UNISOUND_APK_URL="$DOMAIN/$VERSION/$UNISOUND_APK_NAME"
prepare_apk() {
    local apk_path="$1"
    local apk_url="$2"
    wget -O "$apk_path" "$apk_url"
}

prepare_apk "$APK_PATH" "$APK_URL"
prepare_apk "$DLNA_APK_LOCAL_PATH" "$DLNA_APK_URL"
prepare_apk "$UNISOUND_APK_LOCAL_PATH" "$UNISOUND_APK_URL"