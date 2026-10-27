#!/bin/sh
# Undo the BB10 dark theme: put back the original manifests, Hub QML and Hub
# icons, remove the boot addon and set the bright default. Run as root:
#     sh < /var/rootdata/darktheme/uninstall.sh
# then reboot.
A=$(ls -d /apps/sys.pim.messages.*)/native/assets
B=/var/rootdata/manifest_backup
for f in $B/*.MANIFEST.MF; do
    [ -f "$f" ] || continue
    id=$(basename $f .MANIFEST.MF)
    for D in /apps/$id.*; do
        [ -d "$D" ] || continue
        grep "^Package-Name: $id" $D/META-INF/MANIFEST.MF | grep -v "^Package-Name: $id\.[a-z]" > /dev/null || continue
        cp $f $D/META-INF/MANIFEST.MF && echo "restored $id manifest"
    done
done
for H in /var/rootdata/hub_qml_backup /var/rootdata/hub_png_backup; do
    [ -d $H ] || continue
    cd $H
    n=0
    for f in $(find . -name "*.qml" -o -name "*.png"); do
        cp $f $A/$f && n=$((n+1))
    done
    echo "restored $n Hub files from $H"
done
cd /
rm -rf /var/addons/darktheme
echo "defaultTheme::white" >> /pps/services/deviceproperties
grep defaultTheme /pps/services/deviceproperties
echo "now reboot"
