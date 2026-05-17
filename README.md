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

- **Base:** CachyOS (Arch-based, x86_64-v3 optimised)
- **Desktop:** Quickshell on Hyprland — single curated configuration, no DE picker
- **Installer:** Calamares
- **Repo:** `shokunin` pacman repo hosted at `repo.ceereals.space`
- **Branding:** own name, wallpaper, plymouth, grub theme, `/etc/os-release`

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
| Understand the layering vs. CachyOS          | `docs/architecture.md`         |
| Build the ISO locally                        | `iso/README.md`                |
| Add or modify a package                      | `packages/README.md`           |
| Cut a release                                | `docs/release-process.md`      |
| Understand the pacman.conf ordering          | `docs/pacman-conf-reference.md`|
| Deploy / debug the package repo              | `repo/README.md`               |
| Tweak the installer                          | `calamares/README.md`          |

## Status

Early scaffolding. Most files are skeletons with TODOs. See
`OPEN_QUESTIONS.md` for design decisions still on the table.

## Repository layout note

The legacy `archiso/`, `buildiso.sh`, `util-*.sh`, `machines/`, and
`testcases/` directories at the root are inherited from the upstream
`CachyOS/cachyos-iso` fork. They are kept for reference while
`iso/` is bootstrapped and may be removed once `iso/build.sh` reaches
parity.

## License

- Code: **GPL-3.0-or-later** (see `LICENSE`)
- Branding (wallpaper, plymouth/grub themes, logos): **CC-BY-SA-4.0**
  (per-asset notice next to each file)
