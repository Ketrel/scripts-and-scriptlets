#!/bin/sh
dirPick(){
    _fpickDir=''
    _fprevDir=''
    _forigDir=''
    _fret=''
    chosenDir=''
    if [ -z "${1}" ] || [ ! -d "${1}" ]; then
        _fstartDir='/'
    else
        _fstartDir="${1}"
    fi

    if [ -n "${2}" ] && [ -d "${2}" ]; then
        _fprevDir="${2}"
    fi

    _forigDir="$(pwd)"

    if [ -r "${_fstartDir}" ]; then

        cd "${_fstartDir}"

        # Hopefully resolving ..
        _fstartDir="$(pwd)"

        # echo "Delving into ${_fstartDir}" #Debug Option
        _flisting=$(find ./ -maxdepth 1 -type d ! -name "." ! -name '*"*' -exec printf '"%s" OFF\n' '{}' \; | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ' )

        if [ "${tuiBin}" = "dialog" ]; then
            _fpickDir=$(eval "DIALOGRC=${mainRC} dialog --no-items --radiolist \"Choose A Directory: ${_fstartDir}\" 24 80 16 '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        else
            _fpickDir=$(eval "NEWT_COLORS_FILE=\"${mainRC}\" whiptail --noitem --radiolist \"Choose A Directory: ${_fstartDir}\" 24 80 16 '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        fi
        _fret="${?}"

        # shellcheck disable=2181
        if [ "${_fret}" -ne "0" ] || [ -z "${_fpickDir}" ]; then
            printf 'Unhandled Case\n'
            printf 'Debug Stack\n fpick: %s\n fprev: %s\n forig: %s\n fret: %s\n chosen: %s\n\n' "${_fpickDir}" "${_fprevDir}" "${_forigDir}" "${_fret}" "${chosenDir}"
            exit 17
        fi

        cd "${_forigDir}"

        if [ "${_fpickDir}" = "<This Directory>" ]; then
            chosenDir="${_fstartDir%/}"
        elif [ "${_fpickDir}" = ".." ] && [ -r "${_fstartDir%/}/.." ]; then
            dirPick "${_fstartDir%/}/.." "${_fstartDir}"
        elif [ -r "${_fstartDir%/}/${_fpickDir}" ]; then
            dirPick "${_fstartDir%/}/${_fpickDir}" "${_fstartDir}"
        else
            printf 'Unhandled Case\n'
            printf 'Debug Stack\n fpick: %s\n fprev: %s\n forig: %s\n fret: %s\n chosen: %s\n\n' "${_fpickDir}" "${_fprevDir}" "${_forigDir}" "${_fret}" "${chosenDir}"
            exit 27
        fi
    else
        printf 'Unreadable Initial Dir: %s\n' "${_fstartDir}"
        exit 7
    fi
}

