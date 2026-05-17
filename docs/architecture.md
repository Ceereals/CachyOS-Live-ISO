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
       │  shokunin-quickshell-… │         │                             │
       └────────────────────────┘         └─────────────────────────────┘
              ▲                                          ▲
              │                                          │
       owned by us                              maintained upstream
       (this monorepo)                          (CachyOS / Arch)
```

The user's machine fetches the **same kernel, mesa, and 99 % of
everything else** as a plain CachyOS install. Shokunin contributes:

- a meta-package that picks which CachyOS-and-upstream packages get
  installed by default,
- branding (wallpaper, plymouth, grub theme, `/etc/os-release`),
- a single curated desktop config (Quickshell on Hyprland),
- a keyring + mirrorlist for our own repo so pacman trusts and fetches
  the above.

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

## What happens if CachyOS changes X?

| Change in CachyOS                          | Impact on Shokunin                                          |
| ------------------------------------------ | ----------------------------------------------------------- |
| Kernel bump (`linux-cachyos` 6.x → 6.y)    | None. Our `shokunin-base` depends on `linux-cachyos`, not a version. |
| Mesa / driver bump                         | None. We don't touch mesa.                                  |
| Repo URL changes                           | Update `iso/profile/{,airootfs/etc/}pacman.conf`. CI lint catches drift. |
| `[cachyos-v3]` is renamed / removed        | Update both `pacman.conf`s and `shokunin-mirrorlist`.       |
| CachyOS drops `linux-cachyos` for a fork   | Bump `shokunin-base` `depends=()` to the new name; bump pkgver. |
| Default DE / installer is changed upstream | No impact. We bring our own installer and DE.               |

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
