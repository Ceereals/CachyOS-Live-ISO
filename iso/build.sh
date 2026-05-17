#!/usr/bin/env bash
# build.sh — thin wrapper around mkarchiso for the Shokunin live ISO.
#
# Why a wrapper instead of calling mkarchiso directly?
#   - We want a single command to run locally AND in CI.
#   - We want predictable output paths.
#   - We want clean failure modes (no half-written ISOs).
#
# Run as root (mkarchiso requires it for mount/loop operations):
#     sudo ./iso/build.sh
#
# Override paths via env vars if needed:
#     WORK_DIR=/tmp/shokunin-work OUT_DIR=./out sudo -E ./iso/build.sh

set -euo pipefail

# Resolve script-relative paths so the wrapper works regardless of CWD.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROFILE_DIR="${SCRIPT_DIR}/profile"
WORK_DIR="${WORK_DIR:-${SCRIPT_DIR}/../work}"
OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/../out}"

# Sanity: must be root for mkarchiso (it loops, mounts, chroots).
if [[ ${EUID} -ne 0 ]]; then
  echo "build.sh: must be run as root (mkarchiso requires it)" >&2
  exit 1
fi

# Sanity: profile must exist and be a directory.
if [[ ! -d "${PROFILE_DIR}" ]]; then
  echo "build.sh: profile directory missing at ${PROFILE_DIR}" >&2
  exit 1
fi

# Sanity: mkarchiso must be installed.
if ! command -v mkarchiso &>/dev/null; then
  echo "build.sh: mkarchiso not found. Install with: pacman -S archiso" >&2
  exit 1
fi

mkdir -p "${WORK_DIR}" "${OUT_DIR}"

echo "build.sh: profile  = ${PROFILE_DIR}"
echo "build.sh: work dir = ${WORK_DIR}"
echo "build.sh: out dir  = ${OUT_DIR}"

# -v: verbose; -w: work dir; -o: output dir.
# The profile dir is the final positional argument.
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"

echo "build.sh: ISO written under ${OUT_DIR}"
