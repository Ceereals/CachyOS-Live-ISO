#!/usr/bin/env bash
# customize_airootfs.sh — runs inside the airootfs chroot during mkarchiso.
#
# Purpose: live-ISO-specific setup. None of this lands on the INSTALLED
# system; it only ends up in the squashfs of the live medium. The
# installed system's configuration is handled by:
#   - the shokunin-* packages (system defaults)
#   - Calamares modules (per-install user choices)
#
# Convention: archiso runs this script (by name) after pacstrap.

set -euo pipefail

# ─── Live user ──────────────────────────────────────────────────────────
# Passwordless, in wheel for sudo, fish as shell (ADR-0009).
useradd \
  --create-home \
  --groups wheel,audio,video,input,storage,lp,network \
  --shell /usr/bin/fish \
  liveuser
passwd --delete liveuser

# Drop password requirement for sudo in the live env only. The INSTALLED
# system follows ADR-0014 ("sudo senza password mai"). This file is
# inside the squashfs, not on the target disk.
install -Dm440 /dev/stdin /etc/sudoers.d/99-live-nopass <<'EOF'
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

# ─── greetd: autologin liveuser into Hyprland ───────────────────────────
# Override the system config shipped by shokunin-shell-defaults with a
# live-env variant. initial_session = autologin; default_session is the
# fallback if autologin is disabled at the cmdline.
install -Dm644 /dev/stdin /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user    = "greeter"

[initial_session]
command = "Hyprland"
user    = "liveuser"
EOF

# ─── Calamares autostart inside liveuser's Hyprland session ─────────────
# Append to the hyprland.conf already deposited via /etc/skel by
# shokunin-shell-defaults. `sleep 2` gives the compositor a beat to
# settle so polkit/UI can find the running session.
mkdir -p /home/liveuser/.config/hypr
cat >> /home/liveuser/.config/hypr/hyprland.conf <<'EOF'

# --- Live ISO additions ------------------------------------------------
# Auto-launch the installer once the session is up.
exec-once = sleep 2 && calamares
EOF
chown -R liveuser:liveuser /home/liveuser

# ─── Service activation ─────────────────────────────────────────────────
# Only what the LIVE env needs. The installed system gets services
# enabled by Calamares' services-systemd module.
systemctl enable greetd.service
systemctl enable NetworkManager.service
systemctl enable systemd-resolved.service
systemctl enable bluetooth.service              || true   # not always shipped
systemctl enable iwd.service                    || true

# Pipewire stack runs as user units — enable for liveuser.
systemctl --global enable pipewire-pulse.socket
systemctl --global enable wireplumber.service

# Don't enable nftables / opensnitch / usbguard in the live env — the
# install needs unfettered net access, and there's no point firewalling
# a transient session.
