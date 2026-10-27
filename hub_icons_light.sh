#!/bin/sh
# BlackBerry Hub: the dark-grey PNG icons (sent/sending, attachment, flag,
# lock, archive, swipe actions, file types, S/MIME...) are drawn for a white
# background. hub_icons/ holds them lightened (grey pixels: black -> #a8a8a8,
# coloured pixels untouched; made by tools/make_icons.py from OS 10.3.3.3216).
# Originals saved once in /var/rootdata/hub_png_backup.
A=$(ls -d /apps/sys.pim.messages.*)/native/assets
N=/var/rootdata/darktheme/hub_icons
B=/var/rootdata/hub_png_backup
n=0
cd $N
for f in $(find . -name "*.png"); do
  [ -f "$A/$f" ] || continue
  if [ ! -f "$B/$f" ]; then mkdir -p "$B/${f%/*}"; cp "$A/$f" "$B/$f" || continue; fi
  cp "$f" "$A/$f" && n=$((n+1))
done
echo "lightened $n Hub icons"
