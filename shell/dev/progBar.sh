#!/bin/sh

tpBold="$(tput bold)"
tpRed="$(tput setaf 1)"
tpGreen="$(tput setaf 2)"
tpReset="$(tput sgr0)"

progBar() {
    pBcur="${1:-0}"
    pBtotal="${2:-25}"
    pBleft="${3:-"$(tput setaf 2; tput bold)"}"
    pBright="${4:-"$(tput setaf 1; tput bold)"}"
    pBreset="$(tput sgr0)"
    i=${pBtotal}

    
    #echo "Not Done Yet"

    printf '%s' "${pBleft}"
    while [ $i -ge 1 ] && [ $pBcur -ge 1 ]; do
        printf '|'
        i=$(( i - 1 ))
        pBcur=$(( pBcur - 1 ))
    done

    printf '%s' "${pBright}"
    while [ $i -ge 1 ]; do
        printf '|'
        i=$(( i - 1 ))
    done
    printf '%s' "${pBreset}"

    #printf '%s (%d/100)\n' "${tpReset}" "${pbLV}"
}
progBarSum () {
    progBar "${1}" "${2}" "${4}" "${5}"
    printf '%s/%s\n' "${1}" "${2}"        
}

# if [ -t 0 ]; then
#     progBar "${1}" "${2}" "${3}" "${4}"
# else
#     echo "debug msg"
# fi
