#!/bin/sh
i=0
while [ $i -lt $(($(tput colors) - 0 )) ]; do 
# LC_NUMERIC="en_US.UTF-8" 
    printf "%-3d:%s%*s%s\n" $i $(tput setab $i) 10 ' ' $(tput sgr0)
    i=$(($i + 1))
done
