#!/bin/sh
# AutoRoot V4 boot addon: /var/addons/darktheme/init/start.sh (with an empty
# /var/addons/darktheme/data next to init/). Runs as root ~8 min after boot.
#
# Cascades apps read the default theme from PPS deviceproperties when the app
# zygote (/bin/cascades /dev/cascades) starts; every app is forked from it.
# deviceproperties is not persistent (back to "white" at every boot), so:
# set "black", kill the zygote (the launcher respawns it in ~15 s), then
# restart the always-running apps that were forked from the old one.
# At boot (no argument) the apps are restarted only once the screen is off
# and no call is active, so nothing closes while the phone is in use.
# "start.sh now" restarts them immediately (used by install.sh).
LOG=/var/rootdata/darktheme.log
APPS="libsys.pim.messages libphone libsys.pim.contacts libsys.pim.calendar EmailCard EmailComposeCard NotificationsCard AttachmentsCard libsettings libDTGBootstrap libsys.chat libpictures libsys.filepicker"

restart_apps() {
    for pat in $APPS; do
        for p in $(pidin -F "%a %A" | grep "app/native/$pat" | grep -v grep | while read a b; do echo $a; done); do
            kill -9 "$p" 2>/dev/null
        done
    done
}

DARK=0
grep -q "^defaultTheme::black" /pps/services/deviceproperties && DARK=1
if [ $DARK = 0 ]; then
    echo "defaultTheme::black" >> /pps/services/deviceproperties
    for p in $(pidin -F "%a %A" | grep "/bin/cascades /dev/cascades" | grep -v grep | while read a b; do echo $a; done); do
        kill "$p"
    done
    sleep 20
fi

# "now" restarts the apps even if the theme was already dark: install.sh
# needs it to load the patched Hub files
if [ "$1" = now ]; then
    restart_apps
    echo "$(date) dark theme: apps restarted" >> $LOG
    exit 0
fi
if [ $DARK = 1 ]; then
    echo "$(date) theme already dark" >> $LOG
    exit 0
fi
# wait for screen off (brightness 0) and no call; check once a minute, 12 h max
wait_and_restart() {
    n=0
    while [ $n -lt 720 ]; do
        b=$(sed -n 's/^CurrentBrightness:n://p' /pps/services/backlight/display0/state)
        c=$(sed -n 's/^phone_state:://p' /pps/services/phone/public/status)
        case "$b" in 0|0.0|0.00|0.000) if [ "$c" = idle ]; then
            restart_apps
            echo "$(date) dark theme: apps restarted (screen off)" >> $LOG
            return
        fi;; esac
        n=$((n + 1)); sleep 60
    done
}
wait_and_restart </dev/null >/dev/null 2>&1 &
echo "$(date) dark theme set, apps restart when the screen is off" >> $LOG
