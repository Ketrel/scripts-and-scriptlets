#!/bin/sh
grep --color=no -e '\(menuentry\|submenu\) ' /boot/grub/grub.cfg \
    | sed -e 's/^\s\{1,\}//' \
    | awk '{print substr($0, index($0,$1))}' \
    | sed -e 's/'"'"'//g' \
          -e 's/--.\+//' \
          -e 's/menuentry /-/' \
          -e 's/submenu /--/' \
          -e 's/ \$menuentry.*$//'
