#!/bin/sh
dirPick(){
    _fpickDir=''
    _fprevDir=''
    _forigDir=''
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

        #Hopefully resolving ..
        _fstartDir="$(pwd)"
        echo "Delving into ${_fstartDir}"
        _flisting=$(find ./ -maxdepth 1 -type d ! -name "." ! -name '*"*' -exec printf '"%s" OFF\n' '{}' \; | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ' )
       
        _fpickDir=$(eval "dialog --no-items --radiolist \"Choose A Directory: ${_fstartDir}\" 24 80 16 '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        # _fpickDir=$(eval "whiptail --noitem --radiolist \"Choose A Directory: ${_fstartDir}\" 24 80 16 '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
            
        # shellcheck disable=2181
        if [ "${?}" -ne "0" ] || [ -z "${_fpickDir}" ]; then
            exit 7
        fi

        cd "${_forigDir}"

        if [ "${_fpickDir}" = "<This Directory>" ]; then
            chosenDir="${_fstartDir%/}/"
        elif [ "${_fpickDir}" = ".." ] && [ -r "${_fstartDir%/}/.." ]; then
            dirPick "${_fstartDir%/}/.." "${_fstartDir}"
        elif [ -r "${_fstartDir%/}/${_fpickDir}" ]; then
            dirPick "${_fstartDir%/}/${_fpickDir}" "${_fstartDir}"
        else
            printf 'Unhandled Case\n'
            exit 9
        fi
    else
        echo "Unreadable Initial Dir: ${_fstartDir}"
        exit 9
    fi
}   
