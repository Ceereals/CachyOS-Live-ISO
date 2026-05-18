# Shokunin — Architecture Decision Records

> **Shokunin** (職人): artigiano giapponese che persegue la padronanza del proprio mestiere per dovere etico verso l'opera e verso chi la userà. Pialla la trave che resterà nascosta perché *deve* essere fatta bene comunque.

Questo documento raccoglie le decisioni architetturali significative di Shokunin. Ogni decisione è un ADR (Architecture Decision Record) auto-contenuto.

L'obiettivo non è essere esaustivi, ma documentare le scelte che richiedono spiegazione o che qualcuno (incluso il futuro me) potrebbe voler riconsiderare.

## Filosofia di prodotto

North star da usare come riferimento per ogni decisione futura:

> Shokunin è una CachyOS curata per uno sviluppatore Wayland terminale-first che vive in Hyprland, integra AI nel workflow, e vuole massimo controllo con safety net automatiche. Potere a chi capisce, sicurezza per chi non capisce ancora.

Test per ogni nuova feature/pacchetto: *"serve a un dev Wayland che vive in terminale?"* Se no, non entra nel default.

## Formato ADR

- **Status**: `Accepted` | `Proposed` | `Deprecated` | `Superseded by ADR-XXXX`
- **Data**: quando è stata presa la decisione
- **Contesto**: perché serviva decidere
- **Decisione**: cosa è stato scelto
- **Conseguenze**: cosa implica nel pratico (positive e negative)
- **Alternative considerate**: cosa è stato scartato e perché

## Indice

1. [ADR-0001 — Base upstream: CachyOS](#adr-0001--base-upstream-cachyos)
2. [ADR-0002 — Bootloader: limine](#adr-0002--bootloader-limine)
3. [ADR-0003 — Filesystem: Btrfs + snapper + snap-pac](#adr-0003--filesystem-btrfs--snapper--snap-pac)
4. [ADR-0004 — Cifratura: LUKS2 + TPM2 + Secure Boot](#adr-0004--cifratura-luks2--tpm2--secure-boot)
5. [ADR-0005 — Compositor: Hyprland](#adr-0005--compositor-hyprland)
6. [ADR-0006 — Shell desktop: Quickshell + caelestia via layering](#adr-0006--shell-desktop-quickshell--caelestia-via-layering)
7. [ADR-0007 — Strategia tema: matugen dinamico](#adr-0007--strategia-tema-matugen-dinamico)
8. [ADR-0008 — Display manager: greetd + tuigreet](#adr-0008--display-manager-greetd--tuigreet)
9. [ADR-0009 — Terminale, shell, editor, multiplexer](#adr-0009--terminale-shell-editor-multiplexer)
10. [ADR-0010 — Tool CLI: criteri di scelta](#adr-0010--tool-cli-criteri-di-scelta)
11. [ADR-0011 — Browser default: Firefox vanilla](#adr-0011--browser-default-firefox-vanilla)
12. [ADR-0012 — Dev environment: mise + distrobox + podman](#adr-0012--dev-environment-mise--distrobox--podman)
13. [ADR-0013 — AI tooling come prima classe](#adr-0013--ai-tooling-come-prima-classe)
14. [ADR-0014 — Postura sicurezza desktop](#adr-0014--postura-sicurezza-desktop)
15. [ADR-0015 — AUR helper: paru](#adr-0015--aur-helper-paru)
16. [ADR-0016 — Backup: kopia](#adr-0016--backup-kopia)
17. [ADR-0017 — Welcome app: minimale](#adr-0017--welcome-app-minimale)
18. [ADR-0018 — Target hardware: desktop AMD + laptop](#adr-0018--target-hardware-desktop-amd--laptop)
19. [ADR-0019 — Localizzazione: italiano con messaggi C](#adr-0019--localizzazione-italiano-con-messaggi-c)
20. [Non-decisioni: cose esplicitamente fuori scope](#non-decisioni-cose-esplicitamente-fuori-scope)

---

## ADR-0001 — Base upstream: CachyOS

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Shokunin deve avere una distribuzione upstream da cui derivare. Le opzioni includevano Arch vanilla, CachyOS, EndeavourOS, openSUSE Tumbleweed, NixOS.

### Decisione
**CachyOS** come upstream completo. Si usano i repo ufficiali CachyOS (`cachyos`, `cachyos-core-v3`, `cachyos-extra-v3`, `cachyos-v3`) senza forkarli. Shokunin aggiunge un layer di curatela, branding, configurazioni e meta-pacchetti distribuiti via repo proprio `shokunin` su `repo.ceereals.space`.

Il modello di riferimento è EndeavourOS rispetto ad Arch: upstream invariato, valore aggiunto sopra.

### Conseguenze
- **Vincolato**: systemd come init, glibc come libc, pacman come package manager, kernel `linux-cachyos` come default. Vedi sezione "Non-decisioni".
- Aggiornamenti di kernel, mesa, driver, toolchain arrivano gratis da CachyOS.
- Il valore di Shokunin è curatela e integrazione, non fork.
- Per onestà verso upstream: documentazione esplicita che dichiara la derivazione, bug del layer Shokunin gestiti separatamente dal supporto CachyOS.

### Alternative considerate
- **Arch vanilla**: meno ottimizzazioni out-of-the-box, richiederebbe replicare il lavoro di tuning di CachyOS.
- **NixOS**: filosofia dichiarativa eccellente ma curva di apprendimento elevata e cambio di paradigma totale rispetto al setup attuale.
- **openSUSE Tumbleweed**: ottima base ma ecosistema RPM/zypper, allontana dall'expertise esistente.

---

## ADR-0002 — Bootloader: limine

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Serve un bootloader che supporti boot da snapshot Btrfs, abbia UI decente, tempi rapidi, e sia ben integrato con l'ecosistema CachyOS.

### Decisione
**limine** come bootloader di default. CachyOS lo offre già come opzione di prima classe nel suo installer.

### Conseguenze
- Boot rapido, UI pulita, supporto snapshot tramite `limine-snapper-sync` o equivalente.
- Configurazione in `/boot/limine.conf` leggibile come file di testo (coerente con la postura "/etc come prima classe").
- Meno tutorial su Internet rispetto a GRUB; va documentato bene nel pacchetto branding.

### Alternative considerate
- **GRUB**: standard di fatto, ma più lento e UI brutta. Snapshot integration via `grub-btrfs` funziona ma è fragile.
- **systemd-boot**: leggero e veloce, ma minimo supporto a snapshot Btrfs boot menu.
- **rEFInd**: bello visivamente, configurazione più ostica.

---

## ADR-0003 — Filesystem: Btrfs + snapper + snap-pac

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
La risposta "snapshot/rollback immediato" alla domanda *"cosa fai quando un update rompe il sistema?"* indica che la rete di sicurezza è una feature non negoziabile. Questo è probabilmente il singolo upgrade più impattante rispetto a CachyOS vanilla.

### Decisione
**Btrfs** con layout subvolumi standard openSUSE-style:
- `@` → `/`
- `@home` → `/home`
- `@var-log` → `/var/log`
- `@var-cache` → `/var/cache`
- `@.snapshots` → `/.snapshots`

**snapper** per gestione snapshot, **snap-pac** per snapshot automatici pre/post `pacman`, integrazione con **limine** via `limine-snapper-sync` per boot da snapshot.

### Conseguenze
- Ogni `pacman -Syu` crea automaticamente snapshot pre e post update.
- Rollback in 30 secondi: reboot, scelgo snapshot precedente da menu limine, `snapper rollback`.
- `/home` ha snapshot separati con policy diversa (più infrequenti, più lunghi).
- Spazio disco: gli snapshot occupano poco (copy-on-write), ma vanno monitorati. Policy default di snapper è ragionevole (10 ultimi + 10 giornalieri + 4 settimanali).
- Btrfs su SSD ha qualche caveat di tuning (`noatime`, `compress=zstd:1`, niente CoW su database/VM); documentato nel pacchetto sysctl/mount.

### Alternative considerate
- **ext4 + LVM snapshot**: snapshot di LVM sono pesanti e poco pratici per uso desktop.
- **ZFS**: tecnicamente superiore in alcuni aspetti ma fuori dal kernel mainline, complicazioni di licenza e maintenance con kernel updates.
- **bcachefs**: promettente ma non ancora maturo per default desktop.

---

## ADR-0004 — Cifratura: LUKS2 + TPM2 + Secure Boot

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
La postura sicurezza dichiarata è "massima sempre". Il target include laptop (futuro), quindi cifratura disco è imprescindibile. Vogliamo che sia abilitata di default senza opt-out facile.

### Decisione
- **LUKS2** full-disk encryption obbligatoria, configurata nell'installer
- **TPM2 auto-unlock** via `systemd-cryptenroll` (su hardware compatibile)
- **Secure Boot** enrollment via **sbctl** guidato dalla welcome app al primo boot
- Recovery key generata all'install e mostrata all'utente con istruzioni di salvataggio fuori dal disco

### Conseguenze
- Su desktop fisso, dopo enrollment TPM2, il sistema sblocca senza chiedere password finché non cambia la configurazione del firmware o del bootloader.
- Su laptop rubato senza password utente, il disco resta inaccessibile.
- Secure Boot con chiavi proprie (non Microsoft) significa: niente boot di kernel di altre distro live senza disable manuale.
- Complicazione: kernel updates richiedono firma automatica. Gestita da hook pacman che firma il vmlinuz e initramfs via sbctl.

### Alternative considerate
- **LUKS solo senza TPM**: più sicuro contro attacchi sofisticati, ma password ad ogni boot. Default troppo fastidioso, lasciato come opt-out.
- **Niente Secure Boot**: una capa di sicurezza in meno contro evil maid attacks; non giustificato dato che sbctl rende l'enrollment indolore.

---

## ADR-0005 — Compositor: Hyprland

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Serve un compositor Wayland come scelta primaria. Il profilo utente è "tiling con eccezioni floating sensate".

### Decisione
**Hyprland** come compositor di default. Tiling come modo principale, ma con regole `windowrulev2` curate per popup GTK/Qt, dialog modali, file picker, picture-in-picture, e app desktop pesanti (Blender, GIMP) che vanno floating per scelta.

### Conseguenze
- Pacchetti correlati nell'ecosistema: `hypridle`, `hyprlock`, `hyprpicker`, `hyprsunset`, `hyprpaper` o `swww` per wallpaper.
- Configurazione Hyprland distribuita via `/etc/skel/.config/hypr/` nel pacchetto `shokunin-shell-defaults`.
- L'utente può ovviamente sostituire qualsiasi keybind/regola; i default sono opinionati ma non locked-in.

### Alternative considerate
- **Sway**: più maturo e stabile, ma feature set più ristretto. Manca scrollable e animazioni.
- **niri**: scrollable tiling interessante, ma paradigma diverso che richiede adattamento. Da rivalutare per Shokunin v2.
- **river**: leggero, pochi maintainer, futuro incerto.
- **KDE Plasma / GNOME**: troppo "general purpose" rispetto al focus dichiarato.

---

## ADR-0006 — Shell desktop: Quickshell + caelestia via layering

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Serve una shell desktop (bar, notifiche, launcher, lockscreen integration, OSD) coerente visivamente, moderna, mantenuta. Pezzi separati (waybar + mako + rofi + swayosd) producono coerenza visiva imperfetta e tante config da mantenere.

### Decisione
**Quickshell** come framework di shell desktop, con **caelestia** come configurazione di partenza, integrata via **layering** (non fork).

Architettura:
- `shokunin-base` dipende da `caelestia-meta` (AUR rebuildato nel nostro repo) + `quickshell` + tutte le sue dipendenze runtime
- Nuovo pacchetto `shokunin-shell-defaults` installa override Shokunin in `/etc/skel/` e `/etc/xdg/quickshell/caelestia/`
- Override per singoli widget QML in file separati, mai forkando l'intero repo upstream
- Eventuale futuro pacchetto `shokunin-shell-overrides` per quando si scriveranno componenti propri (es. widget AI)

Sostituiti da caelestia: waybar, mako/swaync, rofi/wofi, swayosd. Conservati come utility separate: hypridle, hyprpicker, grimblast, satty, cliphist.

Launcher integrato di caelestia è basato su **fuzzel** (Wayland-native).

### Conseguenze
- Coerenza visiva totale di bar, notifiche, OSD, launcher.
- Manutenzione: aggiornamenti caelestia arrivano gratis, gli override sono piccoli.
- Curva di apprendimento QML per modifiche profonde, ma il giorno 1 funziona senza tocchi.
- Qt6 + QtDeclarative + QtWayland nelle dipendenze (peso ~150MB, accettabile).
- Strategia di versioning: si valuta pinning di `caelestia-shell` a versione testata vs always-latest. Decisione provvisoria: always-latest in v0, pinning quando emergono breaking changes.

### Alternative considerate
- **Waybar + mako + rofi + swayosd**: standard de facto, ma coerenza visiva imperfetta e manutenzione spalmata su 4+ progetti.
- **AGS (Astal)**: valido ma ecosistema più piccolo e meno momentum di Quickshell nel 2026.
- **eww**: bello concettualmente, ma scrivere widget completi è laborioso.
- **end-4/dots-hyprland**: ottima config Quickshell concorrente, valutata e scartata in favore di caelestia per estetica più sobria.

---

## ADR-0007 — Strategia tema: matugen dinamico

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Caelestia integra **matugen** (algoritmo Material You) per generare schemi colore dinamici a partire dal wallpaper. Decisione: forzare uno schema statico (Catppuccin, Tokyo Night, ecc.) o lasciare il dinamico.

### Decisione
**Matugen dinamico**. Lo schema colore si adatta automaticamente al wallpaper corrente.

Implicazioni di distribuzione:
- Set curato di wallpaper default Shokunin scelti per produrre schemi esteticamente coerenti
- Wallpaper rotation è opzione disponibile ma disabilitata di default
- Comando `caelestia wallpaper` resta lo strumento canonico per cambiare wallpaper+tema

### Conseguenze
- Niente "tema Shokunin fisso" — l'identità visiva sta nella scelta dei wallpaper di default e nel design della shell, non in una palette specifica.
- Le app non Qt/QML (terminal, editor) hanno tema indipendente. Per coerenza visiva parziale, le loro config di default useranno schemi neutri (es. terminal con palette che funziona su sfondi vari).
- Cambiamenti di mood frequenti: l'utente cambia wallpaper, tutto si adatta. Lato positivo.
- Difficile testare "come si vede Shokunin" perché dipende dal wallpaper. Mitigato dal set curato.

### Alternative considerate
- **Catppuccin statico**: scartato esplicitamente per scelta dell'utente.
- **Schema statico custom Shokunin**: troppo lavoro di design grafico per la v0.
- **Light/dark adattivo a ora**: complicazione UX poco richiesta.

---

## ADR-0008 — Display manager: greetd + tuigreet

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Serve un display manager leggero, coerente con la postura terminale-first e con uno stile pre-login pulito che non carichi Qt/GTK inutilmente.

### Decisione
**greetd** come servizio display manager, **tuigreet** come greeter TUI.

### Conseguenze
- Login screen testuale, leggero, veloce.
- Avvio sessione Hyprland via `tuigreet --cmd Hyprland` (o `uwsm start hyprland` se si adotta uwsm in futuro).
- Niente "background image" sul display manager — coerente con la postura sobria.
- Configurazione in `/etc/greetd/config.toml`, semplice e versionabile.

### Alternative considerate
- **SDDM**: pesante, default KDE, sovradimensionato per il caso d'uso.
- **GDM**: tightly coupled con GNOME stack.
- **ly**: alternativa TUI valida, meno mantenuta di tuigreet.
- **No display manager** con autologin via uwsm/getty: paranoia di sicurezza (sessione aperta automaticamente al boot non è ideale anche su desktop), scartato.

---

## ADR-0009 — Terminale, shell, editor, multiplexer

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Sono le applicazioni dove l'utente Shokunin passa la maggior parte del tempo. Default opinionati ma classici.

### Decisione
- **Terminal emulator**: ghostty (GPU-accelerated, rendering font eccellente, config TOML)
- **Shell**: fish (autosuggestion/syntax highlight out of the box, zero config)
- **Prompt**: starship
- **Editor TUI**: neovim con preset LazyVim
- **Editor "facile" fallback**: helix nel repo come opt-in
- **Multiplexer**: tmux (standard, conosciuto, stabile)
- **`$EDITOR`**: `nvim`
- **`$VISUAL`**: `nvim`

### Conseguenze
- Kitty resta disponibile come alternativa nel repo per chi non ama ghostty.
- Bash funzionante per script di sistema e fallback, ma fish è la shell utente di default via chsh nell'installer.
- Niente zellij di default per rispetto al principio "maturo > nuovo per moda"; resta installabile.
- Configurazioni di default per tutti questi tool distribuite via `/etc/skel/.config/` nel pacchetto `shokunin-shell-defaults`.

### Alternative considerate
- **kitty come default**: ottimo ma ghostty ha rendering font marginalmente migliore e configurazione più pulita nel 2026.
- **zsh + oh-my-zsh**: tutto buono ma fish ha meno boilerplate.
- **helix come default**: paradigma post-modal interessante ma ecosistema plugin più piccolo di neovim.
- **zellij come default**: più scoperta per nuovi utenti, ma il profilo Shokunin non è "nuovo utente".

---

## ADR-0010 — Tool CLI: criteri di scelta

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
L'utente apprezza tool moderni "ma non a tutti i costi". Bisogna evitare di pushare Rust per moda quando un tool tradizionale funziona altrettanto bene.

### Decisione
Criterio: **un tool moderno entra nel default solo se è oggettivamente migliore** del classico per UX o performance, non solo perché scritto in Rust/Go.

Inclusi nel default:
- `ripgrep` (rg) — sostituisce grep, oggettivamente più veloce e UX migliore
- `fd` — sostituisce find, sintassi sana
- `bat` — sostituisce cat, syntax highlighting + paging integrato
- `eza` — sostituisce ls, output migliore con git status integrato
- `zoxide` — autojump intelligente, complementare a cd
- `delta` — pager git con syntax highlighting (configurato in `/etc/gitconfig`)
- `btop` — top/htop, UX nettamente superiore
- `lazygit` — TUI git, accelera workflow rispetto a CLI nuda
- `yazi` — file manager TUI con preview immagini
- `tealdeer` (tldr) — man page veloci

Esclusi dal default (disponibili nel repo come opt-in):
- `sd`, `dust`, `procs`, `xh`, `gping` — alternative Rust a sed/du/ps/httpie/ping che non aggiungono abbastanza valore per essere default

Esclusi del tutto (sostituiti da meglio):
- `tree` — sostituito da `eza --tree`
- `htop` — sostituito da btop
- `nano` — sostituito da helix (più moderno) o nvim

### Conseguenze
- Profilo di `~/.bashrc` e `~/.config/fish/conf.d/` (via `/etc/skel/`) configura alias espliciti dove sensato (es. `alias cat=bat` opt-in, non forzato — alcuni script assumono cat puro).
- `delta` configurato come pager di default in `/etc/gitconfig`.
- Documentazione nel welcome menziona questi tool senza imporli.

### Alternative considerate
- **Default minimalista assoluto** (solo coreutils GNU): non sfrutta il valore di curatela di Shokunin.
- **Default massimalista** (tutti i tool Rust possibili): vìola il principio "Rust non a tutti i costi".

---

## ADR-0011 — Browser default: Firefox vanilla

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Browser di default è una decisione visibile. Le opzioni considerate: Firefox vanilla, LibreWolf, Zen Browser, niente di default.

### Decisione
**Firefox vanilla** preinstallato. Niente policy hardening forzate.

Script opzionale `shokunin-firefox-harden` disponibile nel repo per applicare configurazione arkenfox-user.js a chi lo vuole. **Opt-in, non default**.

### Conseguenze
- Update freschi direttamente da Mozilla, niente lag di un fork.
- Niente sorprese tipo "il fork rompe un'estensione perché non ha seguito un cambio API".
- L'utente avanzato può sempre installare LibreWolf, Zen, IronFox da AUR/Flatpak.

### Alternative considerate
- **LibreWolf**: privacy migliore out of the box ma rischio di drift dalla mainline.
- **Zen Browser**: UX moderna, ma ancora giovane come progetto per essere default di una distro.
- **Chromium-based**: scartato per coerenza FOSS-first.
- **Niente browser di default**: opzione purista, ma rende l'OS non funzionale al primo boot per casi banali (aprire la documentazione).

---

## ADR-0012 — Dev environment: mise + distrobox + podman

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Le dipendenze di sviluppo (Node, Python, Rust toolchain, Bun, ecc.) possono essere gestite via pacchetti di sistema, version manager, o container. Le combinazioni producono coerenza diversa e diversi livelli di pulizia del sistema.

### Decisione
- **mise** preinstallato e configurato (hook fish/bash in `/etc/skel/`) per gestione versioni linguaggi
- **podman** + **distrobox** preinstallati per ambienti isolati / cross-distro
- **Docker non installato di default**, disponibile nel repo per chi lo vuole esplicitamente
- **Nessun runtime di linguaggio nel meta-pacchetto base**: niente `nodejs`, `python`, `rust`, `go` come dipendenze di sistema (a meno che CachyOS le tiri come dipendenze di altre cose, ma niente di esplicito da parte di Shokunin)

### Conseguenze
- Sistema "magro": niente `python-*` di dipendenze transitive a centinaia.
- Workflow per progetto: `mise use node@22` in repo, oppure `distrobox enter cliente-X` per ambienti isolati con `apt`/`dnf` proprio.
- Lazydocker preinstallato funziona con podman, una sola UI.
- Welcome app può suggerire la creazione della prima distrobox come step opzionale.

### Alternative considerate
- **Tutto su pacman**: classico ma sporca il sistema e impedisce versioni multiple per progetto.
- **Solo distrobox**: copre tutto ma overhead per ogni operazione, mise leggero è meglio per il caso "voglio Node 22 sull'host".
- **Nix/devbox/devenv**: ottimi tecnicamente ma cambio di paradigma per l'utente.

---

## ADR-0013 — AI tooling come prima classe

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
L'utente integra AI nel flow quotidiano. Differenziatore reale di Shokunin: nessuna distro mainstream è AI-native first. Una distro che al primo boot configura un provider AI e lo rende disponibile in CLI/editor/shell sarebbe una scelta forte di prodotto.

### Decisione
**AI tooling come categoria first-class** del pacchetto base. Preinstallati:
- `claude-code` CLI (configurabile con API key o endpoint LiteLLM)
- `aichat` o equivalente per chat CLI veloce dal terminale
- Plugin Copilot/AI per LazyVim preconfigurato (provider scelto dall'utente al welcome)
- Variabili di ambiente `OPENAI_BASE_URL`, `ANTHROPIC_API_URL` ecc. configurabili da una posizione unica (es. `~/.config/shokunin/ai.env`) che viene caricata dalle shell

Welcome app include step "Configura provider AI" con preset per:
- Claude (Anthropic API key)
- OpenAI
- LiteLLM endpoint custom (per chi ha gateway self-hosted)
- Skip / configuro dopo

### Conseguenze
- Vero differenziatore di prodotto rispetto ad altre Arch-based.
- Manutenzione: AI tooling cambia rapidamente; il pacchetto Shokunin va aggiornato spesso.
- Nessuna telemetry o uso di AI senza opt-in esplicito (coerente con postura privacy).

### Alternative considerate
- **AI come opt-in totale**: Shokunin non lo include, l'utente lo installa da AUR. Più pulito filosoficamente ma butta via il differenziatore.
- **Welcome più aggressivo che forza un provider**: viola il principio "potere all'utente".

---

## ADR-0014 — Postura sicurezza desktop

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Postura dichiarata "massima sempre". Defaults sani sono critici, ma senza compromettere usabilità al punto di forzare l'utente a disabilitarli.

### Decisione
Difese a strati:
- **LUKS2 + TPM2** (vedi ADR-0004)
- **Secure Boot via sbctl** (vedi ADR-0004)
- **AppArmor** abilitato con profili per servizi critici
- **nftables firewall** con drop incoming + allow outgoing di default
- **opensnitch** preinstallato e configurato come opt-in (per controllo outbound per-app)
- **usbguard** preinstallato in modalità "allow all" di default, attivabile via welcome per chi vuole blocco USB sconosciuti (utile soprattutto su laptop)
- **flatseal** preinstallato per gestione permessi Flatpak
- **systemd-resolved** in modalità DoT verso un resolver privacy-friendly (Quad9 di default, configurabile)
- **Flatpak + Flathub** abilitati out of the box
- **sudo senza password mai**, neanche per comodità

### Conseguenze
- Setup post-install richiede 1-2 minuti di welcome per Secure Boot e firewall outbound.
- Su laptop, usbguard attivo è significativo (blocca data exfiltration).
- DoT verso resolver esterno: l'utente può cambiare verso AdGuard self-hosted facilmente.
- Flatpak sandboxing più sicuro dei pacchetti pacman, ma installazione si fa caso per caso.

### Alternative considerate
- **SELinux invece di AppArmor**: profili più granulari ma curva di apprendimento alta e meno integrato con Arch ecosystem.
- **firejail per tutto**: utile ma intrusivo come default.
- **DNS in chiaro**: scartato, contraddice la postura privacy.

---

## ADR-0015 — AUR helper: paru

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Serve un AUR helper per pacchetti che non sono nei repo Shokunin/CachyOS/Arch ufficiali. Le opzioni storiche sono `yay` e `paru`.

### Decisione
**paru** preinstallato come AUR helper di default.

### Conseguenze
- Scritto in Rust, ben mantenuto nel 2026.
- Sintassi simile a pacman, curva di apprendimento minima.
- Configurazione in `/etc/paru.conf` versionabile.

### Alternative considerate
- **yay**: storicamente più popolare ma manutenzione più lenta recentemente.
- **aurutils**: più "puro" e scriptabile, ma meno user-friendly come default.

---

## ADR-0016 — Backup: kopia

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Snapshot Btrfs locali (ADR-0003) coprono il caso "rollback dopo update rotto". Non coprono "disco morto" o "casa bruciata". Serve backup off-machine.

### Decisione
**kopia** preinstallato. Welcome app include step opzionale "Configura backup" che guida la creazione di un repository kopia verso:
- Backblaze B2
- S3 generico (utile per chi self-hosta MinIO)
- SFTP / rsync.net
- WebDAV
- Filesystem locale (per chi ha NAS montato)
- Skip / configuro dopo

Servizio systemd `kopia-backup.timer` installato disabilitato, attivato dalla welcome se l'utente configura il backup.

### Conseguenze
- Backup encrypted di default da kopia, nessuna config aggiuntiva richiesta.
- Coerente con il workflow self-hoster (B2, S3-compatible).
- Notifiche di successo/fallimento via swaync o caelestia notifications.

### Alternative considerate
- **restic**: alternativa eccellente, scelta soggettiva tra kopia e restic. Kopia ha UI web integrata che aiuta utenti meno tecnici.
- **borg**: classico ma meno integrato con storage cloud.
- **Niente backup di default**: vìola la postura "safety net automatiche".

---

## ADR-0017 — Welcome app: minimale

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Welcome app al primo boot rischia di diventare un tutorial fastidioso. Va minimale ma non assente, perché alcune scelte di sicurezza vanno guidate (sbctl enrollment, backup, AI provider).

### Decisione
App GTK4 + libadwaita (o eventualmente QML/Quickshell per coerenza). Step minimi:
1. Info sistema (versione Shokunin, kernel, snapshot policy attiva, link docs)
2. Setup Secure Boot enrollment (`sbctl` guidato)
3. Setup AI provider (ADR-0013)
4. Setup backup (ADR-0016)
5. Setup usbguard (ADR-0014) — solo su laptop
6. Bottone "fatto" → chiude, lanciabile manualmente in futuro da `shokunin-welcome`

Niente:
- Selezione wallpaper guidata
- Tutorial di Hyprland
- Account social
- Telemetry opt-in/out (non c'è telemetria, punto)

### Conseguenze
- App secondaria, non blocca il login. L'utente può chiuderla e fare tutto in CLI.
- Manutenzione: ogni nuova feature di sicurezza/AI va valutata se merita uno step.
- Probabilmente è il pezzo che si fa dopo la prima ISO funzionante, non in v0.

### Alternative considerate
- **Niente welcome**: scartato, Secure Boot enrollment a mano è oneroso anche per power user.
- **Welcome verbose con tutorial**: scartato esplicitamente.

---

## ADR-0018 — Target hardware: desktop AMD + laptop

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Shokunin gira principalmente su desktop AMD (Ryzen 7 9700X, RX 9070 XT), ma deve girare anche su laptop in futuro. Niente NVIDIA-first, niente handheld/HTPC.

### Decisione
- **Default hardware target**: desktop e laptop x86_64 con grafica AMD o Intel
- Pacchetti di power management (`power-profiles-daemon` o `tlp`) attivi di default
- Tool laptop-friendly preinstallati: `brightnessctl`, `playerctl`, `wireplumber`
- Hyprland config con keybind per brightness/volume/touchpad gestures (no-op su desktop)
- Lid switch handling sensato di default (sospensione su lid close)
- Bluetooth attivo di default (sul desktop costa poco)
- `linux-firmware` completo nell'ISO per supporto WiFi/Bluetooth out-of-the-box
- NetworkManager con `iwd` come backend (più moderno di wpa_supplicant)

NVIDIA non target ma non bloccato: chi vuole installa `nvidia-dkms` manualmente. Documentazione menziona la cosa.

### Conseguenze
- Una sola ISO copre desktop + laptop senza scelta all'install.
- Nessun overhead per gaming-specific tuning (è desktop neutral).
- Architetture diverse da x86_64 (ARM, RISC-V) fuori scope per v0.

### Alternative considerate
- **ISO separata desktop/laptop**: complica build e maintenance per benefit marginale.
- **NVIDIA-first**: vìola la realtà del setup utente.
- **Multi-arch da subito**: over-engineering per v0.

---

## ADR-0019 — Localizzazione: italiano con messaggi C

**Status:** Accepted
**Data:** 2026-05-18

### Contesto
Utente italiano, ma debuggare errori in italiano è penalizzante (la maggior parte della documentazione e degli error message Google-abili sono in inglese).

### Decisione
- **`LANG=it_IT.UTF-8`** di default (date, numeri, valute in italiano)
- **`LC_MESSAGES=C`** o `en_US.UTF-8` di default (messaggi di sistema in inglese)
- **Keymap console**: `it`
- **Keymap Hyprland**: `it` con opzione `caps:escape` (caps lock → escape)
- **Timezone**: Europe/Rome
- **Locale aggiuntivo `en_US.UTF-8`** generato per fallback

Tutte queste impostazioni configurabili nell'installer Calamares.

### Conseguenze
- L'utente vede `ls` output con date in formato italiano, ma error message in inglese per facilità di troubleshooting.
- Caps:escape è opinionato; ben documentato perché è life-changing per vim/nvim ma può sorprendere chi non lo conosce.
- Layout `it` di default, ma installer permette di scegliere.

### Alternative considerate
- **Tutto in italiano**: penalizza il troubleshooting.
- **Tutto in inglese**: meno comodo per date/numeri formattati.
- **Niente caps:escape**: utente ha workflow neovim-heavy, vale la pena.

---

## Non-decisioni: cose esplicitamente fuori scope

Per chiarezza, queste cose **non** sono in Shokunin per scelta esplicita, non per dimenticanza.

### Vincolato dalla base (ADR-0001)
- **Init system diverso da systemd**: forkare CachyOS per cambiare init significa riscrivere centinaia di unit file. Out of scope.
- **Libc diversa da glibc**: idem, ecosystem Arch assume glibc.
- **Package manager diverso da pacman**: idem.
- **Modello immutable** (à la Bazzite/Silverblue): cambierebbe completamente l'esperienza di curatela. Forse interessante per Shokunin v2 sperimentale, non v1.

### Esplicitamente esclusi per filosofia
- **NVIDIA-first**: non l'hardware target.
- **Gaming-first**: c'è già Bazzite e CachyOS-gaming per quello.
- **HTPC / handheld**: niente Steam Deck mode, niente couch UI.
- **Office suite preinstallata**: LibreOffice pesa ~1GB, lo installa chi lo usa.
- **Email client preinstallato**: troppo personale, non default.
- **Tool legacy**: nano (sostituito da helix), htop (btop), tree (eza --tree), ack (rg).
- **snap (Canonical)**: fuori dall'ecosistema, scelta filosofica.
- **Telemetry**: nessuna, mai. Non c'è proprio.
- **Account online integration**: niente "accedi col tuo Google" da OS.

### Considerati ma non implementati in v0 (potenziali v2)
- **NixOS-style declarative config layer** sopra pacman
- **Multi-arch** (ARM, RISC-V)
- **niri come compositor alternativo** ufficialmente supportato
- **Welcome app in QML/Quickshell** invece di GTK
- **Schema tema statico Shokunin proprio** (oltre matugen)
- **Componenti shell scritti from scratch in QML** (widget AI custom, ecc.)
