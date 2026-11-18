#!/usr/bin/env bash
# Rotate the managed WebCodex service log in place so launchd keeps writing to
# the same inode. Keeps one compressed generation by default.
#
# Usage: rotate-service-log.sh [LOG_PATH]
#   WEBCODEX_SERVICE_LOG_PATH   default log path when no argument is given
#   WEBCODEX_LOG_MAX_BYTES      rotate above this size (default 10 MiB)
#   WEBCODEX_LOG_KEEP           set 0 to skip the compressed generation
set -euo pipefail

log="${1:-${WEBCODEX_SERVICE_LOG_PATH:-}}"
if [ -z "$log" ]; then
  log="$HOME/Library/Logs/WebCodex/service.log"
fi
max="${WEBCODEX_LOG_MAX_BYTES:-10485760}"
keep="${WEBCODEX_LOG_KEEP:-1}"

[ -f "$log" ] || exit 0

size=$(stat -f %z "$log" 2>/dev/null || stat -c %s "$log" 2>/dev/null || echo 0)
[ "$size" -gt "$max" ] || exit 0

if [ "$keep" != "0" ]; then
  gzip -c "$log" > "$log.1.gz" 2>/dev/null || true
  chmod 600 "$log.1.gz" 2>/dev/null || true
fi
# Truncate in place: launchd holds the descriptor, so replacing the file would
# leave it writing to an unlinked inode.
: > "$log"
chmod 600 "$log" 2>/dev/null || true
