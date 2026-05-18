# `calamares/` — Shokunin installer

[Calamares](https://calamares.io/) is the installer GUI. Configuration is
split between branding (visual theme, copy, slideshow) and module
settings (`settings.conf`).

## Layout

```
calamares/
├── branding/
│   └── shokunin/
│       ├── branding.desc       # name, slogan, paths, slideshow ref
│       └── show.qml            # slideshow shown during install
├── modules/                    # /etc/calamares/modules/*.conf overrides
│   ├── bootloader.conf         # limine (ADR-0002)
│   ├── locale.conf             # it_IT.UTF-8 + LC_MESSAGES=en_US (ADR-0019)
│   ├── partition.conf          # Btrfs subvols + LUKS2 (ADR-0003/0004)
│   ├── services-systemd.conf   # which services to enable at first boot
│   ├── users.conf              # default groups, fish shell, password rules
│   └── welcome.conf            # pre-flight checks (RAM/disk/internet)
└── settings.conf               # module sequence + branding selection
```

## How this lands on the ISO

At ISO build time we (will) copy:

| Source                              | Destination on the live ISO                      |
| ----------------------------------- | ------------------------------------------------ |
| `calamares/branding/shokunin/`      | `/etc/calamares/branding/shokunin/`              |
| `calamares/modules/*.conf`          | `/etc/calamares/modules/*.conf`                  |
| `calamares/settings.conf`           | `/etc/calamares/settings.conf`                   |

The copy step is **not yet wired up** in `iso/build.sh`. Until we add it,
test by symlinking these into `/etc/calamares/` on a running live ISO.

## Status

Settings + branding scaffolding plus six module configs (bootloader,
locale, partition, services-systemd, users, welcome) aligned with the
ADRs. Branding QML slideshow still placeholder. Real PNGs (logo,
welcome) not yet committed — see `branding/shokunin/branding.desc`.

See `OPEN_QUESTIONS.md` §7 for the slideshow format decision.

## Useful references

- Calamares docs: https://github.com/calamares/calamares/wiki
- Branding spec: https://github.com/calamares/calamares/blob/calamares/src/branding/README.md
- A good example to crib from: the EndeavourOS `calamares/` directory in
  their ISO repo.
