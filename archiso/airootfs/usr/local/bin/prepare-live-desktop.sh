#!/bin/sh
# Live-desktop preparation for the omarchy-to-cachyos Hyprland live session.

# Workaround for glib trash bug (https://bugzilla.gnome.org/show_bug.cgi?id=748248)
userid=$(id -u "$USER")
if [ ! -d "/.Trash-$userid" ]; then
    sudo mkdir -p "/.Trash-$userid/expunged" "/.Trash-$userid/files" "/.Trash-$userid/info"
    sudo chown -R "$userid" "/.Trash-$userid"
fi
