#!/bin/sh
# Install the BB10 dark theme. Run as root, from the copy of this folder in
# /var/rootdata/darktheme:
#     cd /var/rootdata/darktheme && sh < install.sh
# (feed the script on stdin: "sh install.sh" can be refused from a root SSH shell)
# NOADDON=1 skips the boot addon (if another addon already sets the theme).
D=/var/rootdata/darktheme
if [ ! -f $D/hub_icons_light.sh ]; then
    echo "copy this folder to $D first"
    exit 1
fi
sh < $D/dark_manifests.sh
sh < $D/hub_dark.sh
sh < $D/hub_icons_light.sh
if [ "$NOADDON" != 1 ]; then
    mkdir -p /var/addons/darktheme/init /var/addons/darktheme/data
    cp $D/addon/start.sh /var/addons/darktheme/init/start.sh
    chmod 755 /var/addons/darktheme/init/start.sh
    echo "boot addon installed: /var/addons/darktheme"
fi
# dark now: set the theme, restart the zygote and the open apps
sh -s now < $D/addon/start.sh
grep defaultTheme /pps/services/deviceproperties
echo "done (log: /var/rootdata/darktheme.log)"
