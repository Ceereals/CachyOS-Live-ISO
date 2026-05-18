# Open implementation questions

Decisions on **what** Shokunin ships are tracked in [`ADR.md`](./ADR.md).
This file tracks the open **how** — build/packaging/repo/process choices
that don't shape the product surface but still need a call before v0.1.

Each item has a tentative answer so work can move forward; revisit before
the first real release.

## 1. AUR helper in CI

**Question:** When a package needs an AUR dependency at build time, do we
pull it in via `paru`, `aurutils`, or fetch tarballs manually?

**Proposal:** `aurutils`. Most CI-friendly (no interactive prompts, no sudo
dance), composes well with our own repo (`aur-build` pushes straight into a
local DB), and matches the "no magic" preference.

**Note:** Desktop AUR helper is a separate decision — see
[ADR-0015](./ADR.md#adr-0015--aur-helper-paru) (paru). The CI vs desktop
split is intentional.

## 2. Quickshell / Hyprland config delivery long-term

**Question:** Skel drop (`/etc/skel/.config/{quickshell,hypr}/`) is fine
for v0. Do we eventually move to an Omarchy-style git-tracked
`~/.config/shokunin/` that the user keeps in sync via `shokunin-update`?

**Proposal:** Skel for v0 (matches [ADR-0006](./ADR.md#adr-0006--shell-desktop-quickshell--caelestia-via-layering)
and standard distro practice — no sourcing footgun, user owns the file
post-install). Document that upgrades will NOT overwrite the user's
config; significant changes ship the canonical source in
`/usr/share/shokunin/` for diffing. Revisit Omarchy pattern once the
config surface stabilises.

## 3. Branding split

**Question:** One `shokunin-branding` package or split into
`shokunin-wallpapers`, `shokunin-plymouth`, `shokunin-grub-theme`?

**Proposal:** One package for now (less moving parts, single version
bump). Split later if any single asset starts versioning on its own
cadence. Note: [ADR-0002](./ADR.md#adr-0002--bootloader-limine) means we
need a `limine-theme` slot, not `grub-theme`.

## 4. GPG signing key custody

**Question:** Where does the repo signing private key live? GitHub secret
encrypted at rest, hardware token (YubiKey) on the Swiss server, or both?

**Proposal:** Two subkeys off one offline master. Signing subkey 1 lives
as a GitHub Actions secret (CI signs packages). Signing subkey 2 lives on
the Swiss server (manual signs / hotfixes). Master key offline on
encrypted USB. Revocation cert printed and stored separately. Master only
touched to rotate subkeys.

## 5. Repo layering: one repo or testing/stable split?

**Question:** Single `shokunin` repo, or `shokunin` + `shokunin-testing`
from day one?

**Proposal:** Single repo until we have real users. Adding `-testing`
later is cheap; running two before we even have one is overhead.

## 6. ISO kernel selection

**Question:** Do we ship `linux-cachyos` alone or also `linux-cachyos-lts`
in the ISO? Affects size by ~150 MB.

**Proposal:** `linux-cachyos` only in the live env (default per
[ADR-0001](./ADR.md#adr-0001--base-upstream-cachyos)). Installer offers
LTS as an opt-in checkbox (Calamares module). Single ISO per
[ADR-0018](./ADR.md#adr-0018--target-hardware-desktop-amd--laptop), so
keep the download small.

## 7. Calamares branding format

**Question:** Stick with QML for `show.qml`, or use the simpler image-list
slideshow format?

**Proposal:** Image-list slideshow until we have actual content worth
animating. QML is more powerful, but the slideshow is one file plus PNGs,
which matches the "no magic" rule.

## 8. Quickshell + caelestia versioning

**Question:** Pin tagged releases or follow `-git` AUR packages?

**Proposal (provisional, per
[ADR-0006](./ADR.md#adr-0006--shell-desktop-quickshell--caelestia-via-layering)):**
always-latest in v0 to flush out integration issues fast, switch to
pinned tagged releases as soon as breaking changes start landing.
Vendoring forks remains off the table.

## 9. Omarchy-style tooling: `shokunin-update` / sub-commands?

**Question:** Omarchy ships `omarchy-update`, `omarchy-cmd-*`, an
`omarchy-tui` helper. Do we replicate that surface from day one or wait
until we feel the pain?

**Proposal:** Wait. Ship just `shokunin-update` (a thin wrapper around
`pacman -Syu` plus our pre/post hooks — Btrfs snapshot per
[ADR-0003](./ADR.md#adr-0003--filesystem-btrfs--snapper--snap-pac), sbctl
re-sign per [ADR-0004](./ADR.md#adr-0004--cifratura-luks2--tpm2--secure-boot))
as part of `shokunin-base`. Add more sub-commands when a real workflow
demands them, not before. Tied to question #2 above.
