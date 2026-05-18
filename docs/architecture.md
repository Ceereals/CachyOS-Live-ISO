# Architecture

How Shokunin layers on top of CachyOS, and what we deliberately do
*not* do.

## The flow

```
                  ┌──────────────────────────────────────────┐
                  │                User's box                 │
                  │                                          │
                  │     /etc/pacman.conf  (repo order):      │
                  │       1. [shokunin]      ← us            │
                  │       2. [cachyos-v3]    ← upstream      │
                  │       3. [cachyos-core-v3]               │
                  │       4. [cachyos-extra-v3]              │
                  │       5. [cachyos]                       │
                  │       6. [core] [extra] [multilib]       │
                  └─────────────┬────────────────────────────┘
                                │ pacman -Syu
                  ┌─────────────┴────────────────────────────┐
                  │ Network                                  │
                  │                                          │
       ┌──────────┴─────────────┐         ┌──────────────────┴──────────┐
       │  repo.ceereals.space   │         │  mirror.cachyos.org / arch  │
       │  [shokunin]            │         │  [cachyos*] [core] [extra]  │
       │                        │         │                             │
       │  shokunin-base         │         │  linux-cachyos, mesa,       │
       │  shokunin-branding     │         │  systemd, glibc, ...        │
       │  shokunin-keyring      │         │                             │
       │  shokunin-mirrorlist   │         │                             │
       │  shokunin-shell-…      │         │                             │
       └────────────────────────┘         └─────────────────────────────┘
              ▲                                          ▲
              │                                          │
       owned by us                              maintained upstream
       (this monorepo)                          (CachyOS / Arch)
```

The user's machine fetches the **same kernel, mesa, and 99 % of
everything else** as a plain CachyOS install. Shokunin contributes:

- a meta-package (`shokunin-base`) that picks which CachyOS-and-upstream
  packages get installed by default, plus a few small system files —
  `/usr/bin/shokunin-update`, `/etc/nftables.conf`, DoT resolved
  drop-in, sysctl tunables (see ADR-0014),
- branding (wallpaper, plymouth, limine boot branding,
  `/etc/os-release`; ADR-0002),
- a single curated desktop config in `shokunin-shell-defaults`
  (Quickshell + Hyprland, hypridle/hyprlock, ghostty, fish + starship +
  tmux, nvim/LazyVim with claudecode.nvim, /etc/greetd/config.toml;
  ADR-0005…0009),
- a keyring + mirrorlist for our own repo so pacman trusts and fetches
  the above.

For the full set of product choices and the rationale behind each, see
[`ADR.md`](../ADR.md).

## What we do NOT do

- **We do not fork CachyOS packages.** No `linux-shokunin` kernel.
  No mesa rebuild. No re-packaged Hyprland. If we ever feel the urge,
  pause and ask why — the answer is almost always "you don't need to".
- **We do not duplicate Arch / CachyOS work.** Shipping a curated
  Quickshell *config* is on us. Shipping Quickshell *itself* is not —
  we depend on the upstream package.
- **We do not maintain our own infrastructure for kernel updates,
  mesa, glibc.** That's exactly the leverage we get from sitting on
  top of CachyOS.
- **AUR rebuilds happen in our repo, not in tree.** Several packages
  on the meta's depends list — `caelestia-meta`, `claude-code`,
  `aichat`, `mise`, `kopia-bin`, `paru`, etc. — live in AUR. We
  rebuild them into `[shokunin]` so pacman can resolve them. The
  PKGBUILDs in this repo do NOT vendor those sources.

## What happens if CachyOS changes X?

| Change in CachyOS                          | Impact on Shokunin                                          |
| ------------------------------------------ | ----------------------------------------------------------- |
| Kernel bump (`linux-cachyos` 6.x → 6.y)    | None. Our `shokunin-base` depends on `linux-cachyos`, not a version. |
| Mesa / driver bump                         | None. We don't touch mesa.                                  |
| Repo URL changes                           | Update `iso/profile/{,airootfs/etc/}pacman.conf`. CI lint catches drift. |
| `[cachyos-v3]` is renamed / removed        | Update both `pacman.conf`s and `shokunin-mirrorlist`.       |
| CachyOS drops `linux-cachyos` for a fork   | Bump `shokunin-base` `depends=()` to the new name; bump pkgver. |
| Default DE / installer is changed upstream | No impact. We bring our own installer (Calamares) and DE (Hyprland+Quickshell). |
| AUR rebuilds we depend on get broken       | We pin the upstream commit in our `[shokunin]` rebuild PKGBUILDs and bump on green. |

The general rule: changes in CachyOS *packages* never affect us;
changes in CachyOS *repository topology* require one PR to this repo.

## What happens if upstream Arch changes X?

Same story, with one extra hop: CachyOS absorbs the change, we absorb
CachyOS. We do not track Arch directly.

## Why this layering at all?

Two reasons. First, leverage: CachyOS spends real engineer hours
keeping the optimised kernel + drivers fast and stable across rolling
updates. We get all of that for the cost of pointing pacman at one
extra repo. Second, identity: a distro is more than a package list.
Branding, installer, default desktop, and the editorial choice of
*what's preinstalled* is where a remix earns its name.
