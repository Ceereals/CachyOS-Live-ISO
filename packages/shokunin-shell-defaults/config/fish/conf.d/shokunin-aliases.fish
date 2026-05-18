# Shokunin curated aliases (ADR-0010).
#
# Conservative — we don't shadow tools whose scripts assume the GNU
# original. So no `alias cat=bat`, `alias ls=eza`, etc. by default.
# Drop those into your own conf.d/ if you want them.

# eza: a few useful shortcuts that don't collide with `ls`.
if command -q eza
    alias ll  'eza --long --git --icons --group-directories-first'
    alias la  'eza --long --git --icons --group-directories-first --all'
    alias tree 'eza --tree --git-ignore'
end

# git shortcuts that don't fight muscle memory.
alias g    git
alias gs   'git status -sb'
alias gd   'git diff'
alias gl   'git log --oneline --decorate --graph -20'
alias lg   lazygit

# Docker → podman compatibility (ADR-0012).
if command -q podman; and not command -q docker
    alias docker podman
end

# `cd` muscle memory → zoxide.
if command -q zoxide
    alias cdi 'zi'   # `cdi <fuzzy>` for interactive jump
end

# AI quickies (ADR-0013).
if command -q aichat
    alias ai aichat
end
if command -q claude-code
    alias cc claude-code
end

# shokunin-update shortcut.
alias up shokunin-update
