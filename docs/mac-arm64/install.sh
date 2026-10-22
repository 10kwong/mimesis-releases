#!/bin/sh
# 映題 Mimesis · first install (macOS / Linux)
#
#   curl -fsSL "$MIMESIS_BASE/install.sh" | \
#     MIMESIS_BASE="$MIMESIS_BASE" MIMESIS_EXPECTED_SHA="<bootstrap sha256>" sh
#
# The SHA-256 comes from the release notes and pins the bootstrap (Node + installer). The installer
# then verifies the ed25519 signature of the app archive before extracting it. There is no
# promise that Gatekeeper or a company policy will never warn; see docs/local-desktop.md.

set -eu

: "${MIMESIS_BASE:?請設定 MIMESIS_BASE（下載位置）}"
: "${MIMESIS_EXPECTED_SHA:?請設定 MIMESIS_EXPECTED_SHA（安裝檔的 SHA-256）}"

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t mimesis)"
trap 'rm -rf "$TMP"' EXIT INT TERM

URL="${MIMESIS_BASE%/}/bootstrap.tar.gz"
echo "[映題安裝] 下載 $URL"
curl -fsSL "$URL" -o "$TMP/bootstrap.tar.gz"

if command -v shasum >/dev/null 2>&1; then
  GOT="$(shasum -a 256 "$TMP/bootstrap.tar.gz" | awk '{print $1}')"
elif command -v sha256sum >/dev/null 2>&1; then
  GOT="$(sha256sum "$TMP/bootstrap.tar.gz" | awk '{print $1}')"
else
  echo "[映題安裝] 找不到 SHA-256 工具（shasum／sha256sum），為安全起見停止。" >&2
  exit 1
fi

EXPECTED="$(printf '%s' "$MIMESIS_EXPECTED_SHA" | tr 'A-F' 'a-f')"
if [ "$GOT" != "$EXPECTED" ]; then
  echo "[映題安裝] 安裝檔檢查碼不符，已停止。" >&2
  echo "  預期：$EXPECTED" >&2
  echo "  實際：$GOT" >&2
  exit 1
fi

tar -xzf "$TMP/bootstrap.tar.gz" -C "$TMP"
if [ ! -x "$TMP/runtime/node" ] || [ ! -f "$TMP/install.mjs" ]; then
  echo "[映題安裝] 安裝檔不完整。" >&2
  exit 1
fi

"$TMP/runtime/node" "$TMP/install.mjs" --base "$MIMESIS_BASE"
