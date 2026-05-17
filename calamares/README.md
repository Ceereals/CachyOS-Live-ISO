# `calamares/` — Shokunin installer

[Calamares](https://calamares.io/) is the installer GUI. Configuration is
split between branding (visual theme, copy, slideshow) and module
settings (`settings.conf`).

## Layout

```
calamares/
├── branding/
│   └── shokunin/
│       ├── branding.desc   # name, slogan, paths, slideshow ref
│       └── show.qml        # slideshow shown during install
└── settings.conf           # module sequence + global settings
```

## How this lands on the ISO

At ISO build time we (will) copy:

| Source                              | Destination on the live ISO                      |
| ----------------------------------- | ------------------------------------------------ |
| `calamares/branding/shokunin/`      | `/etc/calamares/branding/shokunin/`              |
| `calamares/settings.conf`           | `/etc/calamares/settings.conf`                   |

The copy step is **not yet wired up** in `iso/build.sh`. Until we add it,
test by symlinking these into `/etc/calamares/` on a running live ISO.

## Status

Scaffolding only. The slideshow QML is a placeholder, the settings file
declares the standard module sequence but most modules are at defaults.
Building this out is intentionally deferred — it's the largest piece of
work and we want the ISO booting first.

See `OPEN_QUESTIONS.md` §7 for the slideshow format decision.

## Useful references

- Calamares docs: https://github.com/calamares/calamares/wiki
- Branding spec: https://github.com/calamares/calamares/blob/calamares/src/branding/README.md
- A good example to crib from: the EndeavourOS `calamares/` directory in
  their ISO repo.
