#!/bin/sh

. ./progBar.sh

max=50
current=0
step=2

printf '%s' "$(tput civis)"
progBar "${current}" "${max}"
printf '\r'
while [ $current -lt $max ]; do
    current=$(( current + step ))
    sleep 0.25
    progBar "${current}" "${max}"
    #printf '%s %s' "${current}" "${max}"
    printf '\r'
done
sleep 0.5
progBar "${max}" "${max}"
printf '\n'
printf '%s' "$(tput cnorm)"
exit 7
progBar "${1}" "${2}" "${3}" "${4}"
