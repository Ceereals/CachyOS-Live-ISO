# ~/.config/fish/config.fish — Shokunin fish defaults (ADR-0009).
#
# fish auto-sources every .fish file under conf.d/ in lexical order
# AFTER this file. Put modular things there; keep this one for the
# global flow.

# Suppress fish's default greeting — starship's prompt is the only
# "you're in fish" signal we want.
set -g fish_greeting

# ─── Editor (ADR-0009) ──────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SYSTEMD_EDITOR nvim

# ─── PATH additions (no-ops if dirs don't exist) ─────────────────────────
fish_add_path -a ~/.local/bin
fish_add_path -a ~/.cargo/bin
fish_add_path -a ~/go/bin

# ─── Tool initializers ──────────────────────────────────────────────────
# Only run if the binary is present. Lets users uninstall a tool without
# breaking their shell on the next login.

# starship — interactive prompt (ADR-0009).
if status is-interactive; and command -q starship
    starship init fish | source
end

# zoxide — autojump (ADR-0010).
if status is-interactive; and command -q zoxide
    zoxide init fish | source
end

# mise — language version manager (ADR-0012).
if command -q mise
    mise activate fish | source
end

# fzf — keybinds + history widgets, if it's installed.
if status is-interactive; and command -q fzf
    fzf --fish | source
end
