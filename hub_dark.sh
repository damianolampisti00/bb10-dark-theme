#!/bin/sh
# BlackBerry Hub (sys.pim.messages): its QML hardcodes white backgrounds and
# dark text. Recolour them: backgrounds dark, text light.
# Originals saved once in /var/rootdata/hub_qml_backup; the recolour always
# starts from them, so running this again is safe.
A=$(ls -d /apps/sys.pim.messages.*)/native/assets
B=/var/rootdata/hub_qml_backup
# 1. backup of the originals, keeping the directory layout. A file already in
#    the backup is never copied again: the one in /apps may be recoloured.
n=0
cd $A
for f in $(find . -name "*.qml"); do
  [ -f "$B/$f" ] && continue
  mkdir -p "$B/${f%/*}"
  cp "$f" "$B/$f" && n=$((n+1))
done
echo "backed up $n original QML files"
# 2. recolour from the originals
n=0
cd $B
for src in $(find . -name "*.qml"); do
  dst=$A/$src
  [ -f "$dst" ] || continue
  sed -e '/[Bb]ackground\|bgColor\|bg_color\|BgColor/s/Color\.White/Color.create("#121212")/g' \
      -e '/[Bb]ackground\|bgColor\|bg_color\|BgColor/s/"#[fF][fF][fF][fF][fF][fF]"/"#121212"/g' \
      -e '/[Bb]ackground\|bgColor\|bg_color\|BgColor/s/"#[fF][aA][fF][aA][fF][aA]"/"#1a1a1a"/g' \
      -e '/[Bb]ackground\|bgColor\|bg_color\|BgColor/s/"#[fF]0[fF]0[fF]0"/"#1e1e1e"/g' \
      -e '/[Bb]ackground/s/"#[cC][aA][cC][aA][cC][aA]"/"#3a3a3a"/g' \
      -e '/[Bb]ackground/s/"#[cC]6[cC]6[cC]6"/"#3a3a3a"/g' \
      -e '/[Bb]ackground/!s/"#191919"/"#e8e8e8"/g' \
      -e '/[Bb]ackground/!s/"#262626"/"#f2f2f2"/g' \
      -e '/[Bb]ackground/!s/"#323232"/"#e6e6e6"/g' \
      -e '/[Bb]ackground/!s/"#555555"/"#b8b8b8"/g' \
      -e '/[Bb]ackground/!s/"#646464"/"#a8a8a8"/g' \
      $src > /tmp/hubq.tmp && cp /tmp/hubq.tmp $dst && n=$((n+1))
done
rm -f /tmp/hubq.tmp
echo "recoloured $n QML files"
