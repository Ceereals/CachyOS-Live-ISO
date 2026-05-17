# GRUB theme placeholder

Drop a GRUB theme directory here. Minimum files for a working theme:

```
theme.txt            # the theme definition GRUB parses
background.png       # fullscreen background
icons/               # menu entry icons (optional)
fonts/               # PF2 fonts compiled with grub-mkfont (optional)
```

Reference docs: https://www.gnu.org/software/grub/manual/grub/html_node/Theme-file-format.html

GRUB activates the theme via `/etc/default/grub`:

```
GRUB_THEME="/usr/share/grub/themes/shokunin/theme.txt"
```

A future Calamares post-install hook will set that line and run
`grub-mkconfig`.

Once real files land, update `sha256sums=()` in `../PKGBUILD`.
