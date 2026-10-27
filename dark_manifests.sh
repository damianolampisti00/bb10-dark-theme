#!/bin/sh
# Apps that force the bright theme (CASCADES_THEME=bright in the Entry-Point
# of their MANIFEST.MF) ignore the system default: switch them to dark.
# Persistent; originals saved once in /var/rootdata/manifest_backup.
B=/var/rootdata/manifest_backup
mkdir -p $B
# Hub, email viewer/composer, attachments. Contacts, Calendar, BBM, Chat and
# RCS also force bright, but they have not been checked in dark: not listed.
for id in sys.pim.messages sys.pim.email.card sys.pim.email.composer.card sys.pim.attachments.card; do
  for D in /apps/$id.*; do
    [ -d "$D" ] || continue
    M=$D/META-INF/MANIFEST.MF
    # /apps/sys.pim.messages.* also matches sys.pim.messages.foo: skip those
    grep "^Package-Name: $id" $M | grep -v "^Package-Name: $id\.[a-z]" > /dev/null || continue
    grep "^Entry-Point:.*CASCADES_THEME=bright" $M > /dev/null || continue
    [ -f $B/$id.MANIFEST.MF ] || cp $M $B/$id.MANIFEST.MF
    sed "/^Entry-Point:/s/CASCADES_THEME=bright/CASCADES_THEME=dark/" $M > /tmp/manifest.new && cp /tmp/manifest.new $M
    echo "$id: dark"
  done
done
rm -f /tmp/manifest.new
