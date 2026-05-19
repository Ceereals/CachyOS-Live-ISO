# CachyOS Live ISO — omarchy-to-cachyos edition

A stripped-down CachyOS live ISO that ships with **Hyprland only** (no KDE Plasma)
and bundles the `omarchy-to-cachyos` command, which fetches and runs
[Ceereals/omarchy-on-cachyos](https://github.com/Ceereals/omarchy-on-cachyos)
to turn a freshly installed CachyOS into an Omarchy-on-CachyOS system.

## Flow

1. Boot the ISO → autologin on tty1 → Hyprland starts via `uwsm`.
2. Use the live session to install CachyOS to disk with Calamares
   (Super+I in Hyprland, or run `sudo -E calamares` from a terminal).
3. Reboot into the installed system, log in on tty1 (Hyprland autostarts
   from `~/.bash_profile`).
4. Run `omarchy-to-cachyos` as your user — it clones the upstream
   installer and runs it, which installs Omarchy on top of CachyOS.

The pieces of Omarchy that conflict with CachyOS defaults (boot loader,
network backend, NVIDIA drivers, walker pinning, etc.) are patched by
the upstream installer.

## Build

```bash
sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools grub --needed
sudo ./buildiso.sh -p desktop -v -w
```

The resulting ISO appears in `out/`.

### buildiso flags

```
$ ./buildiso.sh -h
Usage: buildiso [options]
    -c                 Disable clean work dir
    -r                 Enable building in RAM on systems with more than 23GB RAM
    -w                 Remove build directory (not the ISO) after ISO file is built
    -h                 This help
    -p <profile>       Buildset or profile [default: desktop]
    -v                 Verbose output to log file, show profile detail (-q)
```
