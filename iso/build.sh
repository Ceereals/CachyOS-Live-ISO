#!/usr/bin/env bash
# build.sh — thin wrapper around mkarchiso for the Shokunin live ISO.
#
# Why a wrapper instead of calling mkarchiso directly?
#   - We want a single command to run locally AND in CI.
#   - We want predictable output paths.
#   - We want clean failure modes (no half-written ISOs).
#   - We need to splice ../calamares/ into the profile's airootfs at
#     build time without dirtying the in-tree profile.
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
CALAMARES_DIR="${SCRIPT_DIR}/../calamares"
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

# Stage the profile in a temp dir so we can splice in Calamares config
# without modifying the in-tree iso/profile/. The staged copy is what
# mkarchiso reads; it goes away on exit.
STAGE_DIR="$(mktemp -d -t shokunin-iso-XXXXXX)"
trap 'rm -rf "${STAGE_DIR}"' EXIT
STAGED_PROFILE="${STAGE_DIR}/profile"
cp -a "${PROFILE_DIR}" "${STAGED_PROFILE}"

# Splice ../calamares/ into the staged airootfs at /etc/calamares/. The
# Calamares package's own defaults under that path get overwritten by
# our settings.conf, modules/*.conf, and branding/.
if [[ -d "${CALAMARES_DIR}" ]]; then
  cal_dst="${STAGED_PROFILE}/airootfs/etc/calamares"
  install -d "${cal_dst}"
  install -Dm644 "${CALAMARES_DIR}/settings.conf" "${cal_dst}/settings.conf"
  cp -r "${CALAMARES_DIR}/branding" "${cal_dst}/branding"
  cp -r "${CALAMARES_DIR}/modules"  "${cal_dst}/modules"
  echo "build.sh: staged Calamares config → ${cal_dst}"
fi

echo "build.sh: profile (staged) = ${STAGED_PROFILE}"
echo "build.sh: work dir         = ${WORK_DIR}"
echo "build.sh: out dir          = ${OUT_DIR}"

# -v: verbose; -w: work dir; -o: output dir.
# The profile dir is the final positional argument.
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${STAGED_PROFILE}"

echo "build.sh: ISO written under ${OUT_DIR}"
