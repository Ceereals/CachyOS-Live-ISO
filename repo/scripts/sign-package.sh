#!/usr/bin/env bash
# sign-package.sh — sign a .pkg.tar.zst with the Shokunin repo key.
#
# Used by CI before upload so the host never needs the private key.
# Produces a detached binary signature next to the input file
# (suffix .sig).
#
# Usage:
#   sign-package.sh <pkg.tar.zst> [<pkg.tar.zst> ...]
#
# Configuration via env vars:
#   GPG_KEY    fingerprint or key ID of the signing key (required)
#   GPG_HOME   optional alternate GNUPGHOME directory

set -euo pipefail

die() { printf '[sign-package] ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '[sign-package] %s\n' "$*"; }

[[ $# -ge 1 ]] || die "usage: $0 <pkg.tar.zst> [<pkg.tar.zst> ...]"
[[ -n "${GPG_KEY:-}" ]] || die "GPG_KEY env var is required"

if [[ -n "${GPG_HOME:-}" ]]; then
  export GNUPGHOME="${GPG_HOME}"
fi

for pkg in "$@"; do
  [[ -f "${pkg}" ]] || die "not a file: ${pkg}"
  if [[ -f "${pkg}.sig" ]]; then
    log "skipping (already signed): ${pkg}"
    continue
  fi
  log "signing: ${pkg}"
  gpg --batch --yes \
      --detach-sign \
      --no-armor \
      --local-user "${GPG_KEY}" \
      --output "${pkg}.sig" \
      "${pkg}"
done

log "done"
