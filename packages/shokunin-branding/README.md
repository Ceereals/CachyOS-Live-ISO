# `shokunin-branding/`

Visual identity for Shokunin. The PKGBUILD packages whatever lives in
this directory and installs it under `/usr/share/`, plus `/etc/os-release`.

## What to drop in here

| File / dir                | What it should be                                                  |
| ------------------------- | ------------------------------------------------------------------ |
| `wallpaper.png`           | 16:9 PNG, ≥ 3840×2160, sRGB. Referenced by the default Quickshell. |
| `plymouth/`               | A plymouth theme directory. See `plymouth/README.md`.              |
| `limine/`                 | Limine boot branding (wallpaper + conf snippet). See `limine/README.md`. |
| `os-release`              | Already shipped; edit only the URL/SUPPORT fields.                 |

At scaffolding time the wallpaper and theme dirs are empty placeholders.
`makepkg` will fail on missing sources until you drop real files in.

## License for branding assets

Branding assets are **CC-BY-SA-4.0**. When you add a wallpaper or theme,
drop a `LICENSE` or `AUTHORS` file next to it with the original author
and source so we can comply with attribution.

## How the installed system picks these up

- **Wallpaper:** the default Quickshell config in `shokunin-shell-defaults`
  references `/usr/share/backgrounds/shokunin/wallpaper.png`.
- **Plymouth:** the user (or a Calamares post-install hook, future work)
  runs `sudo plymouth-set-default-theme -R shokunin` to activate.
- **Limine (ADR-0002):** assets land under `/usr/share/limine/themes/shokunin/`.
  A Calamares post-install hook (future work) copies the wallpaper onto
  the ESP and adds `include: boot():/EFI/limine/shokunin/shokunin.conf`
  to `/boot/limine.conf`.
