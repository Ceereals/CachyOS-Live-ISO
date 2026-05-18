# Limine branding placeholder

Limine (ADR-0002) doesn't have a "theme format" the way GRUB does;
branding is a handful of directives inside `limine.conf`. We ship the
assets and a snippet that gets included from the system config.

Drop these here:

```
wallpaper.png        # boot-menu background; PNG, JPEG, or BMP
shokunin.conf        # limine.conf snippet with branding directives
```

Example `shokunin.conf` (gets included by `/boot/limine.conf` via
`include`):

```
interface_branding: Shokunin
interface_branding_colour: 6
term_palette: 1d1f21;cc6666;b5bd68;f0c674;81a2be;b294bb;8abeb7;c5c8c6
wallpaper: boot():/EFI/limine/shokunin/wallpaper.png
```

Reference docs: https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md

Install path used by the PKGBUILD: `/usr/share/limine/themes/shokunin/`.
A future Calamares post-install hook will copy these onto the ESP and
add the `include` line to `/boot/limine.conf`.
