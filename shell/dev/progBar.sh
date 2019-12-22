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

    
    echo "Not Done Yet"

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
    printf '%s\n' "${pBreset}"

    return

    if [ -n "${2}" ]; then
        shift
        tmp="${*}"
        printf '%s\n  ' "${tmp}"
    fi
    wfSSC=$(( wfSS / 4 ))
    printf '%s' "${tpBold}${tpGreen}"
    while [ $i -ge 1 ] && [ $wfSSC -ge 1 ]; do
        printf '|'
        i=$(( i - 1 ))
        wfSSC=$(( wfSSC - 1 ))
    done
    printf '%s' "${tpRed}"
    while [ $i -ge 1 ]; do
        printf '|'
        i=$(( i - 1 ))
    done
    printf '%s (%d/100)\n\n' "${tpReset}" "${wfSS}"
}

progBar 10 30
progBar ${1} ${2}
