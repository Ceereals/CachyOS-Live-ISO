# Release process

The Shokunin release artefacts are: signed packages on
`repo.ceereals.space` (continuous) and ISO images on GitHub Releases
(tagged + weekly).

## Continuous releases — packages

Every merge to `main` that touches `packages/<name>/` rebuilds and
publishes that one package. No human action required.

The pipeline:

```
PR opened → CI builds + lints → review → merge to main
  → CI builds + signs + scp's .pkg.tar.zst + .sig to server
  → CI runs add-package.sh over SSH
  → pacman clients pick up on next -Sy
```

If anything in the chain breaks, the package is **not** published. The
repo always reflects what was last fully verified.

## Tagged releases — ISO

Cut a tag → CI builds an ISO → uploads to GitHub Releases.

### Checklist

Before tagging, run through this manually. CI lint catches some of it;
some is judgement.

- [ ] `pacman -Syu` on a Shokunin VM completes cleanly (or on a fresh
      CachyOS install with `[shokunin]` added).
- [ ] `shokunin-base` `pkgver` bumped if any of its `depends=()` are
      new or removed.
- [ ] `iso/profile/pacman.conf` and `iso/profile/airootfs/etc/pacman.conf`
      have the same `[section]` order. Diff them by hand.
- [ ] `packages.x86_64` does not reference a package that's not in the
      repo or a configured remote.
- [ ] `OPEN_QUESTIONS.md` reviewed — flag any "still tentative" items
      that block this release.
- [ ] CHANGELOG entry written (or skip section if nothing user-visible
      changed since last tag).

### Tag and push

```bash
# Tags are YYYY.MM.DD or YYYY.MM.DD-N for same-day re-spins.
TAG=2026.05.17
git tag -s "${TAG}" -m "Shokunin ${TAG}"
git push origin "${TAG}"
```

The `build-iso.yml` workflow triggers on the tag, runs `iso/build.sh`
in a privileged Arch container, and uploads the `.iso` plus a
`SHA256SUMS` file and a detached signature to a new GitHub Release.

### Smoke test the ISO

Before announcing:

```bash
qemu-system-x86_64 -enable-kvm -m 4G -boot d -cdrom shokunin-*.iso
```

- Live env boots to Quickshell on Hyprland.
- Calamares launches, gets past partition + users + summary.
- `cat /etc/os-release` shows `ID=shokunin`.
- Network (NetworkManager) brings up an interface.

If anything fails: delete the release, fix, re-tag (`YYYY.MM.DD-2`).

## Weekly ISO

A `schedule:` trigger in `build-iso.yml` runs every Monday morning UTC.
Same workflow, but the tag is `weekly-YYYY-WW`. These don't go through
the smoke-test checklist — they're a canary, not a release.

## Hotfixes

Same as tagged releases, just with a higher cadence and a tighter
checklist (no `shokunin-base` bump unless required).
