# `iso/` — Shokunin live ISO

archiso profile for the Shokunin live/installer ISO. Layout follows the
upstream [archiso](https://gitlab.archlinux.org/archlinux/archiso/) and
the CachyOS fork (`CachyOS/cachyos-iso`).

## Layout

```
iso/
├── build.sh                # thin wrapper around mkarchiso (also stages calamares/)
└── profile/                # the archiso profile mkarchiso consumes
    ├── profiledef.sh       # ISO metadata (name, label, build modes)
    ├── packages.x86_64     # packages installed into the live env
    ├── pacman.conf         # pacman.conf used DURING ISO BUILD
    ├── grub/               # UEFI/BIOS grub.cfg — TODO: not yet populated
    ├── syslinux/           # legacy BIOS syslinux config — TODO: not yet populated
    └── airootfs/           # files overlaid on the live root filesystem
        ├── etc/
        │   ├── os-release      # live env os-release (shokunin-branding overwrites on install)
        │   ├── pacman.conf     # pacman.conf SHIPPED INTO INSTALLED SYSTEM
        │   ├── pacman.d/
        │   └── skel/
        └── root/
            └── customize_airootfs.sh   # liveuser + greetd autologin + Calamares autostart
```

## How build.sh stages the profile

`build.sh` does NOT run `mkarchiso` against `iso/profile/` directly.
It first copies `iso/profile/` into a tempdir, then splices
`../calamares/` (`settings.conf`, `branding/`, `modules/`) into the
staged copy at `airootfs/etc/calamares/`. mkarchiso runs against the
staged path. The tempdir is cleaned up on exit via `trap`.

This keeps `iso/profile/` clean in git — Calamares config lives next
door under `calamares/` (its own README and module index) without
manual sync to two locations.

## The two pacman.conf trap

There are two `pacman.conf` files:

1. `iso/profile/pacman.conf` — used by `mkarchiso` while assembling the
   ISO. Determines what repos packages are pulled FROM at build time.
2. `iso/profile/airootfs/etc/pacman.conf` — copied verbatim into
   `/etc/pacman.conf` on the live (and ultimately installed) system.

**They must stay in sync on repo ORDER and SigLevel.** Drift in ordering
is the most common bug in this kind of project: ISO builds fine, install
appears to work, then `pacman -Syu` on the installed system pulls from
the wrong mirror order and silently overrides our packages.

They are NOT byte-identical on purpose: the build-time copy uses
`Server = …` direct for the `[shokunin]` repo (the mirrorlist file is
not on the build host before pacstrap), while the installed copy uses
`Include = /etc/pacman.d/shokunin-mirrorlist` (shipped by the
`shokunin-mirrorlist` package). Both forms point to the same origin.

When you change one, change the other. A CI lint job will eventually
diff their `[section]` ordering; until then, treat it as a manual
checklist item in `docs/release-process.md`.

## Build locally

Prerequisites (on Arch / CachyOS):

```bash
sudo pacman -S --needed archiso mkinitcpio-archiso squashfs-tools grub
```

Then:

```bash
sudo ./iso/build.sh
```

Output lands in `out/`. Test it with:

```bash
qemu-system-x86_64 -enable-kvm -m 4G -cdrom out/*.iso
```

## CI

`.github/workflows/build-iso.yml` runs this in a privileged Arch
container on tag pushes and a weekly schedule. See that file for the
exact invocation.
