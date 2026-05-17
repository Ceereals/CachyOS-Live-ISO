# `repo/` — server-side hosting for the `[shokunin]` pacman repo

The Shokunin pacman repo lives at `https://repo.ceereals.space/shokunin/`,
served from a Swiss server fronted by Traefik with Cloudflare wildcard
certs. This directory holds the deployment artifacts: the nginx config,
a docker-compose service, and the scripts CI uses to publish packages.

## Layout

```
repo/
├── nginx.conf          # nginx config for autoindex + correct MIME types
├── docker-compose.yml  # nginx container with Traefik labels
└── scripts/
    ├── add-package.sh    # sign (if needed) + repo-add a .pkg.tar.zst
    └── sign-package.sh   # standalone signer used by CI before upload
```

## Layout on the server

```
/srv/shokunin-repo/
└── x86_64/
    ├── shokunin.db -> shokunin.db.tar.gz     # symlink that pacman fetches
    ├── shokunin.db.tar.gz                    # actual DB pacman expects
    ├── shokunin.db.sig                       # detached signature of the DB
    ├── shokunin.files -> shokunin.files.tar.gz
    ├── shokunin.files.tar.gz
    ├── <pkg>-<ver>-<rel>-x86_64.pkg.tar.zst
    └── <pkg>-<ver>-<rel>-x86_64.pkg.tar.zst.sig
```

The `add-package.sh` script wraps `repo-add` to maintain that layout
correctly and atomically.

## Deploy

On the Swiss server (assumes existing Traefik + Cloudflare resolver):

```bash
cd /opt/shokunin-repo
git pull
docker compose -f repo/docker-compose.yml up -d
```

Traefik picks up the service via the labels in `docker-compose.yml` and
issues the cert through the existing Cloudflare DNS-01 resolver.

## Publishing a new package

The CI workflow handles this end-to-end:

1. GitHub Actions builds the package in an Arch container.
2. Signs it with `secrets.SHOKUNIN_GPG_PRIVATE_KEY`.
3. `scp`s the `.pkg.tar.zst` + `.sig` onto the server.
4. Runs `repo/scripts/add-package.sh` over SSH, which calls `repo-add`.
5. Pacman clients pick up the new package on next `-Sy`.

Manual fallback (for hotfixes):

```bash
scp my-package-1.2.3-1-x86_64.pkg.tar.zst* server:/tmp/
ssh server "sudo /opt/shokunin-repo/scripts/add-package.sh /tmp/my-package-1.2.3-1-x86_64.pkg.tar.zst"
```

## Secrets

`docker-compose.yml` reads nothing sensitive. The signing key lives on
GitHub. The SSH key CI uses to reach the server is in
`secrets.SHOKUNIN_DEPLOY_SSH_KEY`; the corresponding pubkey is in
`/root/.ssh/authorized_keys` on the server, restricted to
`command="/opt/shokunin-repo/scripts/add-package.sh"` so a stolen key
can't open a shell. See `OPEN_QUESTIONS.md` §4.
