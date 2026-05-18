#!/usr/bin/env bash
# add-package.sh — add a built .pkg.tar.zst to the Shokunin repo.
#
# Run on the repo host. Idempotent: re-running with the same file is a
# no-op (repo-add detects same version). Re-running with a newer version
# replaces the old entry.
#
# Usage:
#   add-package.sh <path-to-pkg.tar.zst> [<path-to-pkg.tar.zst.sig>]
#
# If the .sig is omitted, the script tries to sign with the
# environment's default GPG key (intended for manual ops on the host;
# CI should pre-sign and pass the .sig explicitly).
#
# Configuration via env vars:
#   REPO_DIR    default: /srv/shokunin-repo/x86_64
#   REPO_NAME   default: shokunin
#   GPG_KEY     default: (empty, uses GPG default)

set -euo pipefail

REPO_DIR="${REPO_DIR:-/srv/shokunin-repo/x86_64}"
REPO_NAME="${REPO_NAME:-shokunin}"
GPG_KEY="${GPG_KEY:-}"

log() { printf '[add-package] %s\n' "$*"; }
die() { printf '[add-package] ERROR: %s\n' "$*" >&2; exit 1; }

# --- Argument parsing ---------------------------------------------------

[[ $# -ge 1 ]] || die "usage: $0 <pkg.tar.zst> [<pkg.tar.zst.sig>]"

PKG_PATH="$1"
SIG_PATH="${2:-}"

[[ -f "${PKG_PATH}" ]] || die "package not found: ${PKG_PATH}"

# Basename sanity: refuse anything that doesn't look like an Arch package.
PKG_FILE="$(basename "${PKG_PATH}")"
if [[ ! "${PKG_FILE}" =~ \.pkg\.tar\.zst$ ]]; then
  die "not an Arch package (expected *.pkg.tar.zst): ${PKG_FILE}"
fi

# --- Signing ------------------------------------------------------------
# If a .sig was passed, just use it. Otherwise sign the package now.

if [[ -n "${SIG_PATH}" ]]; then
  [[ -f "${SIG_PATH}" ]] || die "signature file not found: ${SIG_PATH}"
  log "using provided signature: ${SIG_PATH}"
else
  log "no signature provided, signing locally"
  GPG_ARGS=(--detach-sign --use-agent --no-armor)
  [[ -n "${GPG_KEY}" ]] && GPG_ARGS+=(--local-user "${GPG_KEY}")
  gpg "${GPG_ARGS[@]}" --output "${PKG_PATH}.sig" "${PKG_PATH}"
  SIG_PATH="${PKG_PATH}.sig"
fi

# --- Stage into the repo directory --------------------------------------

mkdir -p "${REPO_DIR}"

# Use --no-clobber-equivalent semantics: if the destination exists and
# has the same checksum, skip. Otherwise replace atomically via mv.
stage_file() {
  local src="$1" dst="$2"
  if [[ -f "${dst}" ]] && cmp -s "${src}" "${dst}"; then
    log "already present (unchanged): $(basename "${dst}")"
    return 0
  fi
  cp -f "${src}" "${dst}.tmp"
  mv -f "${dst}.tmp" "${dst}"
  log "staged: $(basename "${dst}")"
}

stage_file "${PKG_PATH}" "${REPO_DIR}/${PKG_FILE}"
stage_file "${SIG_PATH}" "${REPO_DIR}/${PKG_FILE}.sig"

# --- Update the repo DB -------------------------------------------------

# repo-add is idempotent: same version => no-op; new version => replace
# entry and remove the old file. `-s` signs the DB; `-v` is verbose.
log "running repo-add on ${REPO_NAME}.db.tar.gz"
( cd "${REPO_DIR}" && \
    repo-add -s -v "${REPO_NAME}.db.tar.gz" "${PKG_FILE}" )

log "done"
