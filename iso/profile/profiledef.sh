#!/usr/bin/env bash
# profiledef.sh — mkarchiso reads this to learn about the ISO it's building.
#
# This file is sourced (not executed) by mkarchiso, so variable names
# are fixed by the archiso contract. shellcheck has nothing to lint here
# beyond unused-variable noise.
# shellcheck disable=SC2034

# Human-readable identifier baked into volume label and filenames.
iso_name="shokunin"

# Volume label: 11 chars max for ISO 9660 compatibility. SHO_YYYYMM keeps
# us well under, includes a date for casual ordering, mirrors the CachyOS
# convention (COS_YYYYMM).
iso_label="SHO_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"

iso_publisher="Shokunin <https://repo.ceereals.space>"
iso_application="Shokunin Live/Installer ISO"

# Date-stamped version. SOURCE_DATE_EPOCH lets CI produce reproducible
# builds by pinning the date externally.
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"

# Path under the ISO root that holds the actual install media. "arch" is
# the convention used by Arch and CachyOS, kept for tool compatibility.
install_dir="arch"

# Only producing an .iso; netboot/usb are out of scope.
buildmodes=('iso')

# bios.syslinux: legacy BIOS via syslinux.
# uefi.grub:     UEFI via GRUB (matches CachyOS choice; supports theming).
# systemd-boot is the alternative; we pick GRUB so the live env and the
# installed env can share theme assets.
bootmodes=('bios.syslinux' 'uefi.grub')

arch="x86_64"

# Tells mkarchiso which pacman.conf to use during build. Path is
# resolved relative to the profile directory.
pacman_conf="pacman.conf"

# squashfs is the standard live-rootfs format. xz w/ x86 BCJ is the
# CachyOS default and trades a slower build for a smaller ISO.
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')

# Files that need specific ownership/mode inside the squashfs.
# Format: ["path_in_airootfs"]="uid:gid:mode"
# Add entries here as we add scripts under /usr/local/bin or similar.
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/etc/sudoers.d"]="0:0:750"
)
