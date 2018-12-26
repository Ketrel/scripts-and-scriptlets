#!/bin/sh
case "${*}" in
    *"--help"*|*"-h"*)
        printf 'Help Text Here\n'
        exit 0
        ;;
esac
if [ -n "${1}" ] && [ -f "${1}" ]; then
    if [ -n "${2}" ]; then
        if [ -n "${3}" ]; then
            out="$(awk -v startdate="${2}" -v enddate="${3}" '$1>=startdate && $1<=enddate {print $0}' "${1}")"
        else
            out="$(awk -v startdate="${2}" '$1>=startdate {print $0}' "${1}")"
        fi
        out="$(printf '%s' "${out}" | sed -e '/^[0-9-]\+ [0-9:]\+\s\+<\?-->\?/d')"
    else
        out="$(sed -e '/^[0-9-]\+ [0-9:]\+\s\+<\?-->\?/d' "${1}")"
    fi
    printf '%s\n' "${out}"
else
    echo "File Not Specified or Specified File Does Not Exist"
fi
