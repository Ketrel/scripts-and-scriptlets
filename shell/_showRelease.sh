#!/bin/sh
lsb_release -irc \
    | awk 'BEGIN {ORS=""; FS=":[ \t]+"; sep="";} {print sep toupper(substr($2,1,1)) substr($2,2); sep=" "} END{print "\n";}'
#    | sed -e 's/.$//'
