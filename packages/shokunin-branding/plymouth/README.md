# Plymouth theme placeholder

Drop a plymouth theme directory here. Minimum files for a working theme:

```
shokunin.plymouth        # ini-like metadata
shokunin.script          # plymouth scripting language; drives the animation
background.png           # background frame
logo.png                 # foreground logo
```

Reference docs: https://gitlab.freedesktop.org/plymouth/plymouth

The `shokunin.plymouth` `[Plymouth Theme]` section points
`ImageDir=/usr/share/plymouth/themes/shokunin` and
`ScriptFile=/usr/share/plymouth/themes/shokunin/shokunin.script`.

Once you drop real files in, update `sha256sums=()` in
`../PKGBUILD` so makepkg verifies them on build.
