#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Autostart Hyprland on the first TTY via uwsm (omarchy-style)
if uwsm check may-start 2>/dev/null && [[ "$(tty)" = /dev/tty1 ]]; then
    exec uwsm start hyprland-uwsm.desktop
fi
