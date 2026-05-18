# `packages/` — Shokunin pacman packages

Every package that lives in the `[shokunin]` pacman repo has its source
of truth here.

## Layout

```
packages/
├── shokunin-base/             # meta-package: pulls in everything below
├── shokunin-branding/         # wallpaper, plymouth, limine theme, os-release
├── shokunin-keyring/          # repo signing key
├── shokunin-shell-defaults/   # default skel: quickshell, hypr, ghostty, nvim
└── shokunin-mirrorlist/       # /etc/pacman.d/shokunin-mirrorlist
```

Each package is a directory with a `PKGBUILD` plus any source files
referenced by `source=()`.

## Building locally

You need an Arch / CachyOS system (or container) with `base-devel`.

```bash
cd packages/shokunin-base
makepkg -s                # -s installs missing deps
namcap PKGBUILD           # lint
namcap *.pkg.tar.zst      # post-build lint on the produced package
```

Sign with our key (assumes you have it imported and configured):

```bash
makepkg --sign
```

## Building in CI

`.github/workflows/build-packages.yml` builds every package whose
directory changed in the triggering commit. The CI flow signs with the
key stored in `secrets.SHOKUNIN_GPG_PRIVATE_KEY` and uploads the resulting
`.pkg.tar.zst` to the repo via `repo/scripts/add-package.sh` over SSH.

## Adding a new package

1. Create a subdirectory: `packages/shokunin-yourthing/`.
2. Write a `PKGBUILD`. Keep it shellcheck-clean and commented.
3. Add any source files referenced by `source=()` in the same directory
   (or a URL — prefer in-tree for branding assets).
4. Add the new package to `shokunin-base/PKGBUILD` `depends=()` if it
   should be installed on every Shokunin system.
5. Open a PR. CI will build and lint it. The merge to `main` triggers
   the actual signing + publish.

## Why a meta-package?

`shokunin-base` exists for the same reason `endeavouros-keyring`,
`endeavouros-mirrorlist`, and a meta-package exist on EndeavourOS: they
let us add/remove things from "every Shokunin system" by editing a
single `depends=()` array. No imperative migration scripts, just a
package upgrade.

## Why per-thing keyring/mirrorlist?

Convention. `archlinux-keyring`, `cachyos-keyring`, and our
`shokunin-keyring` all do the same thing for their respective trust
stores. Keeping the pattern means anyone who already knows Arch reads
our setup without surprises.
