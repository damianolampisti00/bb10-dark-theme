#!/bin/sh
# Install the BB10 dark theme. Run as root, from the copy of this folder in
# /var/rootdata/darktheme:
#     cd /var/rootdata/darktheme && sh < install.sh
# (feed the script on stdin: "sh install.sh" can be refused from a root SSH shell)
# The boot addon is installed only when the system default theme is bright
# (e.g. the Q5): the Q10 boots dark already. NOADDON=1 never installs it.
D=/var/rootdata/darktheme
if [ ! -f $D/hub_icons_light.sh ]; then
    echo "copy this folder to $D first"
    exit 1
fi
sh < $D/dark_manifests.sh
sh < $D/hub_dark.sh
sh < $D/hub_icons_light.sh
ADDON=0
if [ "$NOADDON" != 1 ]; then
    # already installed (it may have set "black" itself): keep it up to date
    [ -d /var/addons/darktheme ] && ADDON=1
    grep -q "^defaultTheme::black" /pps/services/deviceproperties || ADDON=1
    [ $ADDON = 0 ] && echo "system theme already dark: boot addon not needed"
fi
if [ $ADDON = 1 ]; then
    mkdir -p /var/addons/darktheme/init /var/addons/darktheme/data
    cp $D/addon/start.sh /var/addons/darktheme/init/start.sh
    chmod 755 /var/addons/darktheme/init/start.sh
    echo "boot addon installed: /var/addons/darktheme"
fi
# dark now: set the theme if needed, restart the open apps (they load the
# patched Hub files)
sh -s now < $D/addon/start.sh
grep defaultTheme /pps/services/deviceproperties
echo "done (log: /var/rootdata/darktheme.log)"
