#!/bin/sh

checkBinary()
{
    if [ "$(command -v "${1}")" ]; then
        return 0        
    else
        printf "${cRed}%b${cReset}\\n" "Error: Specifcied Binary '${1}' Not Found." 
        if [ "${2}" = "optional" ]; then
            printf "${cRed}%b${cReset}\\n\\n" "----\\nWhile the script will work without it, functionality may be limited." 
        else
            printf "${cRed}%b${cReset}\\n\\n" "----\\nThis binary is required for this script to function.\\n If the binary is present on our machine,\\n please ensure it's accessible via your PATH." 
        fi
        return 1
    fi
}

configDimensions()
{
    # 80x25 is the safe assumption
    mainWidth=$(( $(tput cols 2>/dev/null || printf '70' ) * 8 / 10 ))
    mainHeight=$(( $(tput lines 2>/dev/null || printf '15' ) * 8 / 10 ))
    menuHeight=$(( mainHeight - 8 ))
}

dirPick(){
    _fpickDir=''
    _fprevDir=''
    _forigDir=''
    _fprompt=''
    _fret=''
    chosenDir=''
    if [ -z "${1}" ] || [ ! -d "${1}" ]; then
        _fstartDir='/'
    else
        _fstartDir="${1}"
    fi

    if [ -z "${2}" ]; then
        _fprompt="Choose A Directory:"
    else
        _fprompt="${2}"
    fi

    if [ -n "${3}" ] && [ -d "${3}" ]; then
        _fprevDir="${3}"
    fi

    _forigDir="$(pwd)"

    if [ -r "${_fstartDir}" ]; then

        cd "${_fstartDir}"

        # Hopefully resolving ..
        _fstartDir="$(pwd)"

        # echo "Delving into ${_fstartDir}" #Debug Option
        _flisting=$(find ./ -maxdepth 1 -type d ! -name "." ! -name '*"*' -exec printf '"%s" OFF\n' '{}' \; | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ' )

        if [ "${tuiBin}" = "dialog" ]; then
            _fpickDir=$(eval "DIALOGRC=${mainRC} dialog --no-items --radiolist \"${_fprompt} ${_fstartDir}\" ${mainHeight} ${mainWidth} $(( menuHeight - 1 )) '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        else
            _fpickDir=$(eval "NEWT_COLORS_FILE=\"${mainRC}\" whiptail --noitem --radiolist \"${_fprompt} ${_fstartDir}\" ${mainHeight} ${mainWidth} $(( menuHeight - 1 )) '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        fi
        _fret="${?}"

        # shellcheck disable=2181
        if [ "${_fret}" -eq 1 ]; then
            return 1
        elif [ "${_fret}" -ne 0 ] || [ -z "${_fpickDir}" ]; then
            printf 'Unhandled Case\n'
            printf 'Debug Stack\n fpick: %s\n fprev: %s\n forig: %s\n fret: %s\n chosen: %s\n\n' "${_fpickDir}" "${_fprevDir}" "${_forigDir}" "${_fret}" "${chosenDir}"
            exit 17
        fi

        cd "${_forigDir}"

        if [ "${_fpickDir}" = "<This Directory>" ]; then
            chosenDir="${_fstartDir%/}"
        elif [ "${_fpickDir}" = ".." ] && [ -r "${_fstartDir%/}/.." ]; then
            if ! dirPick "${_fstartDir%/}/.." "${_fprompt}" "${_fstartDir}"; then
                return ${?}
            fi
        elif [ -r "${_fstartDir%/}/${_fpickDir}" ]; then
            if ! dirPick "${_fstartDir%/}/${_fpickDir}" "${_fprompt}" "${_fstartDir}"; then
                return ${?}
            fi
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

