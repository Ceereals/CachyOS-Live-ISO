# Open design questions

Decisions noted while bootstrapping Shokunin. Each item has a tentative
answer so work can move forward; revisit before the first real release.

## 1. AUR helper in CI

**Question:** When a package needs an AUR dependency at build time, do we
pull it in via `paru`, `aurutils`, or fetch tarballs manually?

**Proposal:** `aurutils`. It's the most CI-friendly (no interactive
prompts, no sudo dance), composes well with our own repo (`aur-build` can
push straight into a local DB), and matches the "no magic" preference.
`paru` is great for desktops, overkill for headless builders.

## 2. Quickshell config namespace

**Question:** Where do default Quickshell + Hyprland configs land —
`/etc/skel/.config/{quickshell,hypr}/` (copied per user at account
creation) or `/usr/share/shokunin/{quickshell,hypr}/` (sourced from
`~/.config/.../shokunin.conf`)?

**Proposal:** Skel for the initial drop (matches what other distros do, no
sourcing footgun, user owns the file post-install). Document that
upgrades will NOT overwrite the user's config; significant changes ship
the canonical source in `/usr/share/shokunin/` for diffing.

Omarchy reference: ships configs as a git-tracked `~/.config/omarchy/`
that the user keeps in sync via `omarchy-update`. We may revisit and
adopt that pattern (`shokunin-update`) once the config surface stabilises.

## 3. Branding split

**Question:** One `shokunin-branding` package or split into
`shokunin-wallpapers`, `shokunin-plymouth`, `shokunin-grub-theme`?

**Proposal:** One package for now (less moving parts, single version
bump). Split later if any single asset starts versioning on its own
cadence.

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

## 6. ISO size budget

**Question:** Do we ship `linux-cachyos` alone or also `linux-cachyos-lts`
in the ISO? Affects size by ~150 MB.

**Proposal:** `linux-cachyos` only in the live env. The installer can
offer the LTS as an opt-in checkbox (Calamares module). Keeps the
download small.

## 7. Calamares branding format

**Question:** Stick with QML for `show.qml`, or use the simpler image-list
slideshow format?

**Proposal:** Image-list slideshow until we have actual content worth
animating. QML is more powerful, but the slideshow is one file plus PNGs,
which matches the "no magic" rule.

## 8. Quickshell upstream vs. AUR vs. our own build

**Question:** Quickshell is in the AUR (`quickshell-git`) and is moving
fast. Do we (a) depend on `quickshell-git` from AUR rebuilt in CI on a
schedule, (b) pin a tagged release and rebuild on bumps, or (c) vendor a
fork?

**Proposal:** (b) pin to tagged releases of `quickshell` (non-git AUR
package), bump deliberately. Vendoring is overhead we don't need; chasing
git is a recipe for breakage. Reassess once Quickshell hits a stable
release cadence.

## 9. Omarchy-style tooling: shokunin-update / shokunin-tui?

**Question:** Omarchy ships `omarchy-update`, `omarchy-cmd-*`, an `omarchy-tui`
helper. Do we replicate that surface from day one or wait until we feel
the pain?

**Proposal:** Wait. Ship just `shokunin-update` (a thin wrapper around
`pacman -Syu` plus our own pre/post hooks) as part of `shokunin-base`.
Add more sub-commands when a real workflow demands them, not before.
