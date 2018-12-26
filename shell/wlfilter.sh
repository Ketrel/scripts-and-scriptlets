#!/bin/sh

#==========================
#
# TODO: 
#  1. Add checks for correct date format, trigger showHelp if bad
#
#==========================

showHelp() {
    printf '==== Weechat Log Filter ====\n\n'
    printf 'Usage: %s <log file> [start date] [end date]\n\n' "$(basename "${0}")"
    printf 'Start and end dates should be in dashed ISO 8601 Format\n    Example: 2018-01-01\n\n'
}

case "${1}" in
    "-h"|"--help")
        showHelp
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
