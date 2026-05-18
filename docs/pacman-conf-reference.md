# pacman.conf reference

Everything you need to know about the two `pacman.conf` files in this
repo, why they differ, and how to change them without breaking things.

## The two files

| File                                          | Used by                  | Trap                                       |
| --------------------------------------------- | ------------------------ | ------------------------------------------ |
| `iso/profile/pacman.conf`                     | `mkarchiso` at ISO build | Drift from the installed one               |
| `iso/profile/airootfs/etc/pacman.conf`        | The installed system     | Forgetting it exists when editing the first|

## Repository order — canonical

The order is the same in both files and must stay that way:

1. **`[shokunin]`** — our own repo. First so our packages win on name
   collisions.
2. **`[cachyos-v3]`** — x86_64-v3 optimised, replaces upstream when the
   user's CPU supports the v3 ISA.
3. **`[cachyos-core-v3]`** — v3 counterpart of `[core]`.
4. **`[cachyos-extra-v3]`** — v3 counterpart of `[extra]`.
5. **`[cachyos]`** — non-v3 CachyOS packages + CachyOS-only software.
6. **`[core]`** — Arch core (non-optimised fallback).
7. **`[extra]`** — Arch extra.
8. **`[multilib]`** — 32-bit packages.

Reasoning: pacman matches by repo order, first hit wins. So putting
`[shokunin]` first means any package with the same name as one in
CachyOS or Arch gets ours. That's load-bearing — it's how we can
override an upstream package in a pinch without forking.

## SigLevel

Both files use:

```
SigLevel = Required DatabaseOptional
```

at the `[options]` level. Per-repo `SigLevel` overrides are minimal —
only `[shokunin]` explicitly repeats it for clarity. `LocalFileSigLevel =
Optional` so locally built packages (during dev) install without
signing.

## Why the two files are not byte-identical

- `[shokunin]` in `iso/profile/pacman.conf` uses `Server = …` direct,
  because the build host does not yet have
  `/etc/pacman.d/shokunin-mirrorlist` (it ships *inside* the package).
- `[shokunin]` in `iso/profile/airootfs/etc/pacman.conf` uses
  `Include = /etc/pacman.d/shokunin-mirrorlist`, because by the time
  this file is read at runtime, the package is installed and the file
  exists.

The two `Server`/`Include` lines must point to the same origin URL.

## Common edits

### Add a new repo

Both files. Pick a position consistent with the precedence rule above.
Decide whether to `SigLevel` override.

### Change the origin of `[shokunin]`

- Edit `Server = …` in `iso/profile/pacman.conf`.
- Edit the file `packages/shokunin-mirrorlist/mirrorlist` (which becomes
  `/etc/pacman.d/shokunin-mirrorlist` after install).
- Bump `pkgver` in `packages/shokunin-mirrorlist/PKGBUILD`.

### Disable a repo (e.g. multilib)

Comment out the `[multilib]` block in **both** files. Don't delete —
keeping it commented makes it obvious to anyone reading.

## How to verify you didn't break it

```bash
# Same section order, ignoring blank lines and full-line comments.
diff <(grep -E '^\[' iso/profile/pacman.conf) \
     <(grep -E '^\[' iso/profile/airootfs/etc/pacman.conf)
# Expect: empty output.
```

A CI lint should run that exact check. TODO in `.github/workflows/lint.yml`.
