#!/bin/sh
dirPick(){
    if [ -z "${1}" ] || [ ! -d "${1}" ]; then
        _fstartDir=''
    else
        _fstartDir="${1}"
    fi
    _forigDir="$(pwd)"
    cd "${_fstartDir}"
    _flisting=$(find ./ -maxdepth 1 -type d ! -name "." -exec printf '"%s" "" OFF\n' '{}' \; | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ')
    
    # printf '%s\n' "${_flisting}"
    
    # _fpickDir=$(eval "dialog --radiolist 'Choose A Directory' 24 80 16 ${_flisting}  2>&1 1>&3")
    _fpickDir=$(eval "whiptail --radiolist 'Choose A Directory' 24 80 16 ${_flisting}  2>&1 1>&3")
   
    cd "${_forigDir}" 
    _finfoMsg="$(printf 'Original Dir: %s\nBase Dir: %s\nChosen Dir: %s\n' "${_forigDir}" "${_fstartDir}" "${_fpickDir}")"
    _finfoMsg="${_finfoMsg}$(printf -- '-----\nCombined Dir: %s\n\n' "${_fstartDir}/${_fpickDir}")"
    whiptail --yes-button "Use This Dir" --no-button "Choose Subdir" --yesno "${_finfoMsg}" 24 80 
    printf -- '-%s-\n' "${?}"
}
