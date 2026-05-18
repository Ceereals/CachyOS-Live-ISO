# Shokunin

> *Shokunin (職人)* — Japanese for "artisan". The pursuit of mastering
> one's craft by relentless attention to detail, taking responsibility
> for the whole, and serving the user without compromise.

A custom Linux distribution based on [CachyOS](https://cachyos.org/) with
[Quickshell](https://quickshell.outfoxxed.me/) as the only desktop, heavily
inspired by [Omarchy](https://omarchy.org/) for usability and tooling.

Shokunin is to CachyOS what Omarchy is to Arch: a thin opinionated layer on
top of an upstream that does the heavy lifting (kernel, mesa, core packages).
The chef picks; you eat well.

## What this is

- **Base:** CachyOS (Arch-based, x86_64-v3 optimised) — ADR-0001
- **Bootloader:** limine + snapper integration — ADR-0002
- **Filesystem:** Btrfs + snapper + snap-pac for pre/post-pacman snapshots — ADR-0003
- **Encryption:** LUKS2 + TPM2 + Secure Boot (sbctl) — ADR-0004
- **Desktop:** Hyprland + Quickshell (caelestia) — single curated config, no DE picker — ADR-0005/0006
- **Display manager:** greetd + tuigreet — ADR-0008
- **Terminal stack:** ghostty + fish + starship + tmux + nvim/LazyVim — ADR-0009
- **AI tooling first-class:** claude-code CLI + aichat + LazyVim claudecode.nvim — ADR-0013
- **Installer:** Calamares (with module configs for partition/locale/users/bootloader/services)
- **Repo:** `shokunin` pacman repo hosted at `repo.ceereals.space`
- **Branding:** own name, wallpaper, plymouth, limine boot theme, `/etc/os-release`

CachyOS upstream is **not forked**. We add a layer on top via our own pacman
repo and meta-packages. System upgrades keep flowing from CachyOS.

## Quick start (5 min tour)

```
.
├── iso/        # archiso profile + build wrapper                  → iso/README.md
├── packages/   # PKGBUILDs for everything in the shokunin repo    → packages/README.md
├── calamares/  # installer branding + settings                    → calamares/README.md
├── repo/       # server-side hosting (nginx, scripts)             → repo/README.md
├── docs/       # architecture, release process, references        → docs/architecture.md
└── .github/workflows/   # CI: build packages, build ISO, lint
```

## How to navigate

| If you want to…                              | Go to                          |
| -------------------------------------------- | ------------------------------ |
| See *what* Shokunin ships and *why*          | `ADR.md`                       |
| Understand the layering vs. CachyOS          | `docs/architecture.md`         |
| Build the ISO locally                        | `iso/README.md`                |
| Add or modify a package                      | `packages/README.md`           |
| Cut a release                                | `docs/release-process.md`      |
| Understand the pacman.conf ordering          | `docs/pacman-conf-reference.md`|
| Deploy / debug the package repo              | `repo/README.md`               |
| Tweak the installer                          | `calamares/README.md`          |

## Status

Pre-v0.1 bootstrap. The pieces of the distro exist as committed code —
not all of them are tested end-to-end yet.

**What's built:**

- 19 architecture decisions formalised in `ADR.md` (the source of truth
  for product choices).
- Five packages with real content: `shokunin-base` (meta + system
  defaults — `/usr/bin/shokunin-update`, `/etc/nftables.conf`, DoT
  resolved drop-in, sysctl tunables), `shokunin-shell-defaults`
  (Hyprland + hypridle + hyprlock + ghostty + nvim/LazyVim + fish +
  starship + tmux + git skel + greetd), `shokunin-branding`
  (`/etc/os-release` + plymouth/limine placeholders), `shokunin-keyring`
  (placeholders pending real GPG key), `shokunin-mirrorlist`.
- Calamares: `settings.conf` + six module configs (`bootloader.conf`
  for limine, `partition.conf` for Btrfs+LUKS2 subvol layout,
  `locale.conf` for it_IT, `users.conf` for fish/wheel,
  `services-systemd.conf` for first-boot enablement,
  `welcome.conf` for pre-flight checks) + branding scaffolding.
- ISO: `iso/build.sh` stages the profile + splices `calamares/` at
  build time, `customize_airootfs.sh` autologs liveuser into Hyprland
  and autostarts Calamares.
- CI: package builds in matrix with `# shokunin-build: nodeps` opt-in
  for meta-packages, shellcheck at `severity=warning`, namcap on
  PKGBUILDs, pacman.conf order consistency lint, signed publish to
  the repo host on merge to main.

**What needs the maintainer in person** (not autonomously fixable):

- Real GPG signing key for `[shokunin]` repo (see `OPEN_QUESTIONS.md` §4).
- Real branding PNGs: wallpaper, plymouth theme, limine wallpaper,
  Calamares logo (the placeholders in tree are 0-byte stubs).
- `iso/profile/grub/grub.cfg` + `iso/profile/syslinux/syslinux.cfg`
  for the live ISO to actually boot — these need real-hardware testing.
- First end-to-end ISO build run + VM smoke test.

**Where to read next:**

- `ADR.md` — product/architecture decisions (what we ship, what we don't,
  and why). Start here.
- `OPEN_QUESTIONS.md` — residual implementation/process choices still on
  the table (CI tooling, signing custody, repo layering, etc.).

## Repository layout note

The legacy `archiso/`, `buildiso.sh`, `util-*.sh`, `machines/`, and
`testcases/` directories at the root are inherited from the upstream
`CachyOS/cachyos-iso` fork. They are kept for reference while
`iso/` is bootstrapped and may be removed once `iso/build.sh` reaches
parity.

## License

- Code: **GPL-3.0-or-later** (see `LICENSE`)
- Branding (wallpaper, plymouth/limine themes, logos): **CC-BY-SA-4.0**
  (per-asset notice next to each file)
