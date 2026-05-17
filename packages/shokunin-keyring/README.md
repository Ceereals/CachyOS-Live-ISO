# `shokunin-keyring/`

Ships the GPG public key used to sign every package in the `[shokunin]`
pacman repo, plus a post-install hook that makes pacman trust it.

## First-time key generation

You do this **once**, off-CI, on a trusted machine. Output: a master key
+ a signing subkey. Only the signing subkey leaves the machine.

```bash
# 1. Generate a new key pair. Use a strong passphrase. Set expiry to 2y
#    (we rotate; not perpetual).
gpg --quick-generate-key 'Shokunin <repo@ceereals.space>' rsa4096 sign 2y

# 2. Note the long key ID (40-char fingerprint).
gpg --list-keys --with-colons | awk -F: '/^fpr:/ { print $10; exit }'

# 3. Export the public key into the keyring file shipped by this package.
gpg --output shokunin.gpg --export "<KEY_ID>"

# 4. Append the long key ID to shokunin-trusted.
echo "<KEY_ID>" >> shokunin-trusted

# 5. Update sha256sums=() in PKGBUILD with the real checksums.
makepkg -g >> PKGBUILD   # then edit out the SKIPs

# 6. Export the private key, encrypted, store it OFF-MACHINE.
gpg --export-secret-keys --armor "<KEY_ID>" | \
  gpg --symmetric --output shokunin-priv.asc.gpg
# Put shokunin-priv.asc.gpg on encrypted USB. Print revocation cert.
```

## Storing the private key for CI

The signing private key (or, better, a signing-only subkey) is added to
GitHub Actions secrets as `SHOKUNIN_GPG_PRIVATE_KEY` (ASCII-armored)
plus `SHOKUNIN_GPG_PASSPHRASE`. The build workflow imports it ephemerally,
signs, and exits — the key never lands on disk in a long-lived location.

See `OPEN_QUESTIONS.md` §4 for the proposed master/subkey custody plan.

## Never commit

Anything matching `*.key`, `*.asc`, `*-priv.*` is gitignored at the
repo root. Double-check `git status` before pushing.
