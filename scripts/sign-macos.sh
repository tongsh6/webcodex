#!/usr/bin/env bash
# Sign the built WebCodex binaries with the stable local identity used by this
# fork. macOS TCC binds privacy grants to the signing identity; signing every
# build with the same identity keeps existing grants after a rebuild.
#
# Usage: sign-macos.sh [BIN_DIR]   (default: target/dogfood)
#   WEBCODEX_SIGN_IDENTITY  codesign identity, default "WebCodex Local"
set -euo pipefail

dir="${1:-target/dogfood}"
identity="${WEBCODEX_SIGN_IDENTITY:-WebCodex Local}"

for name in webcodex webcodex-server webcodex-runner; do
  codesign --force --sign "$identity" --timestamp=none "$dir/$name"
done
