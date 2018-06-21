#!/bin/sh

# Path Config Options
scriptdir=$( dirname "$(readlink -f "${0}")" )
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"

# Setup variables and defaults
liveRun=''
titleAdditions=' - Dry Run'
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"

if command -v whiptail 1>/dev/null 2>&1 ; then
    tuiBin='whiptail'
elif command -v dialog 1>/dev/null 2>&1; then
    tuiBin='dialog'
else
    printf 'Either Whiptail or Dialog is required\nBut neither was found.\n'
    exit 3
fi

# Loop through args
while [ -n "${1}" ]; do
    case "${1}" in
        '--help'|'-h')
            # If first arg is --help or -h, print help and exit
            printf '%b\n\n' "\
 Setup Script

 Depends On
   tput (Optional)
   highlight (Optional for some functionality)
   dialog or whiptail (At least one is required)

 Usage: $( basename "$(readlink -f "${0}")" ) <options>

 Arguments
   --help, ,-h
     print this help message and exit

   --live
     Actually make changes, defaults to dry run otherwise

   --dialog
     Forces use of dialog
     (script will fail if dialog is not present)"
            exit 0
            ;;
        '--live')
            liveRun='LIVE'
            titleAdditions=' - Live Run'
            shift
            ;;
        '--dialog')
            if command -v dialog 1>/dev/null 2>&1; then
                tuiBin='dialog'
            else
                printf 'Dialog switch used, but dialog not present in path.'
                exit 3
            fi
            shift
            ;;
    esac
done

rcBase="./support_files/mainRC-"
mainRC="${rcBase}${tuiBin}"
export DIALOGRC="${mainRC}"
export NEWT_COLORS_FILE="${mainRC}"

# Ensure infoMsg is empty at this point
infoMsg=''

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '')
cReset=$(tput sgr0  2>/dev/null || printf '')
#cBold=$(tput bold   2>/dev/null || printf '')

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
    # I will use 70x15 as the default to be safe though

    # For whatever reason $(tput cols 2>/dev/null) returns 80, while $(tput cols) returns the actual amount
    if command -v tput; then
        mainWidth=$(( $(tput cols) * 8 / 10 ))
        mainHeight=$(( $(tput lines) * 8 / 10 ))
    else
        mainWidth=$(( 70 * 8 / 10 ))
        mainHeight=$(( 15 * 8 / 10 ))
    fi
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

        cd "${_fstartDir}" || ( printf 'Fatal Error: cd to intiial directory failed\n'; exit 9 )

        # Hopefully resolving ..
        _fstartDir="$(pwd)"

        # echo "Delving into ${_fstartDir}" #Debug Option
        _flisting=$(find ./ -maxdepth 1 -type d ! -name "." ! -name '*"*' -printf '"%f" OFF\n' | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ' )

        if [ "${tuiBin}" = "dialog" ]; then
            _fpickDir=$(eval "dialog --no-items --radiolist \"${_fprompt} ${_fstartDir}\" ${mainHeight} ${mainWidth} $(( menuHeight - 1 )) '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        else
            _fpickDir=$(eval "whiptail --noitem --radiolist \"${_fprompt} ${_fstartDir}\" ${mainHeight} ${mainWidth} $(( menuHeight - 1 )) '<This Directory>' ON '..' OFF ${_flisting}  2>&1 1>&3")
        fi
        _fret="${?}"

        # shellcheck disable=2181
        if [ "${_fret}" -eq 1 ]; then
            return 1
        elif [ "${_fret}" -ne 0 ] || [ -z "${_fpickDir}" ]; then
            printf 'Unhandled Case\n'
            printf 'Debug Stack\n fpick: %s\n fprev: %s\n forig: %s\n fret: %s\n chosen: %s\n\n' "${_fpickDir}" "${_fprevDir}" "${_forigDir}" "${_fret}" "${chosenDir}"
            exit 19
        fi

        cd "${_forigDir}" || ( printf 'Fatal Error: cd back to orignial directory failed\n'; exit 9 )

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
            exit 29
        fi
    else
        printf 'Unreadable Initial Dir: %s\n' "${_fstartDir}"
        exit 7
    fi
}

viewSingleFile(){
    if [ -z "${1}" ]; then
        printf '%b\n' "Pretty Bad Error\\nScript Needs Debugging"
        exit 6
    fi
    cd "${1}" || exit 1
    _ffileList=''
    _ffileList=$(find . -type f ! -name '*"*' -printf '"%f" OFF\n' | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ')
    if [ -n "${_ffileList}" ]; then
        if _fselectedFile=$(eval "${tuiBin} --backtitle \"Setup${titleAdditions}\" \
        --title 'File Select' \
        --noitem \
        --radiolist \"Select A File\" \
        ${mainHeight} \
        ${mainWidth} \
        ${menuHeight} \
        ${_ffileList} \
        2>&1 1>&3"); then
            printf '\033c'
            if [ -n "${_fselectedFile}" ] && command -v highlight 1>/dev/null 2>&1 ; then
                ( highlight -O ansi "${_fselectedFile}" 2>/dev/null || highlight -O ansi -S sh "${_fselectedFile}" ) | less -S -R -# 2
            else
                less -S -r -# 2 "${_fselectedFile}"
            fi
        fi
    fi
}

copyFiles(){
    if [ -z "${1}" ] || [ -z "${2}" ]; then
       printf 'Fatal Program Error: Misuse of function\nExiting\n'
       exit 1
    fi
    if [ -z "${3}" ]; then
        _ftype="files"
    else
        _ftype="${3}"
    fi

    infoMsg="Copying ${_ftype} to \"${2}\""
    if [ "${liveRun}" = "LIVE" ]; then
        if [ "${4}" = "noprofile" ]; then
            find "${1}" -type f ! -name ".profile" -exec cp {} "${2}/" \;
        else
            find "${1}" -type f -exec cp {} "${2}/" \;
        fi
    else
        infoMsg="${infoMsg}\\n    Dry Run: Not Doing Anything for Real"
    fi
}

copySelectedFiles(){
    fileList=''
    checkList=''
    results=''
    chosen=''

    if [ -z "${1}" ] || [ -z "${2}" ]; then
        printf "%b\\n" "Unrecoverable Script Failure\\nNeeds Debugging"
        exit 5
    fi

    cd "${1}" || exit 1
    fileList=$(find . -type f ! -name '*"*' -printf '%f\n' | LC_ALL=C sort -g )
    cd - 1>/dev/null || exit 1

    i=0
    checkList=''
    while read -r line
    do
        i=$((i+1))
        checkList="${checkList}\"${i}\" \"${line}\" \"off\" "
    done <<EOF
${fileList}
EOF
    results=$(eval "${tuiBin} --backtitle \"Setup${titleAdditions}\" \
            --title 'File Select' \
            --checklist \"Select Files\" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            ${checkList} \
            2>&1 1>&3")
    if [ -n "${results}" ]; then
        chosen=$(echo "${results}" | sed -e 's/ /\n/g')

        i=1
        while read -r line
        do
            if grep -E "\\b${i}\\b" >/dev/null <<EOF
${chosen}
EOF
            then
                infoMsg="${infoMsg}\\nCopied \"$(basename "${line}")\" to ${2}"
                if [ "${liveRun}" = "LIVE" ]; then
                    cp "${1}/${line}" "${2}/${line}" || { printf "${cRed}%b${cReset}\\n" "Error Copying Files"; exit 41; }
                else
                    infoMsg="${infoMsg}\\n  DRY RUN: cp \"${1}/${line}\" \"${2}/${line}\""
                fi
            fi
            i=$((i+1))
        done <<EOFF
${fileList}
EOFF
    else
        msgBox "Error: No Files Selected"
        exit 70
    fi
    return 0
}

msgBox(){
    if [ -n "${1}" ]; then
        ${tuiBin} --msgbox "${1}" ${mainHeight} ${mainWidth}
    fi
}

yesnoBox(){
    if [ -n "${1}" ]; then
        ${tuiBin} --yesno "${1}" ${mainHeight} ${mainWidth}
        return $?
    fi
}

showConfig(){
     msgBox "Current Config\\n----------\\n\\nDestination for scripts:\\n ${scriptsDestDir}\\n\\nDestination for dotfiles:\\n  ${dotfilesDestDir}"
}

main(){
    mainMenuReturn='0'
    infoMsg=''

    #while [ "${mainMenuReturn}" = "0" ]; do
    while true; do
        if ! mainMenu; then
            printf 'Exited Main Menu Via Cancel.\nExiting Script.\n'
            exit 0
        fi

        case "${mainMenuReturn}" in
            '1')
                if ! copySelectedFiles "${scriptsDir}" "${scriptsDestDir}" "scripts";  then
                    return 0
                fi
                ;;
            '2')
                if ! copySelectedFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files"; then
                    return 0
                fi
                ;;
            'B')
                bulk
                ;;
            'C')
                options
                ;;
            '?')
                showConfig
                ;;
            'Q')
                printf '\033c'
                exit 0
                ;;
        esac

        if [ -n "${infoMsg}" ]; then
            ${tuiBin} --backtitle "Setup${titleAdditions}" --title "Results" --msgbox "${infoMsg}" ${mainHeight} ${mainWidth}
            infoMsg=''
        fi
    done
}

bulk(){
    bulkMenuReturn='0'
    while true; do
        if ! bulkMenu; then
            return 0
        fi
        case "${bulkMenuReturn}" in
            '1')
                if ! copyFiles "${scriptsDir}" "${scriptsDestDir}" "scripts"; then
                    return 0
                fi
                ;;
            '2')
                if ! copyFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files"; then
                    return 0
                fi
                ;;
            '3')
                if ! copyFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files (excluding .profile)" "noprofile"; then
                    return 0
                fi
                ;;
            '<')
                return 0
                ;;
        esac
    done
}

options(){
    optionsMenuReturn='0'
    while true; do
        if ! optionsMenu; then
            return 0
        fi
        case "${optionsMenuReturn}" in
            '1')
                chosenDir=''
                if [ -d "${scriptsDestDir}" ] && [ -r "${scriptsDestDir}" ]; then
                    dirPick "${scriptsDestDir}" 'Choose a scripts directory.\nCurrently Viewing: '
                    dirRet=${?}
                elif [ -d "${HOME}" ] && [ -r "${HOME}" ]; then
                    dirPick "${HOME}" 'Choose a scripts directory.\nCurrently Viewing: '
                    dirRet=${?}
                else
                    dirPick "/" 'Choose a scripts directory.\nCurrently Viewing: '
                    dirRet=${?}
                fi
                if [ "${dirRet}" -eq 1 ]; then
                    msgBox "Canceled\\nScripts Directory Unchanged\\nCurrent Value: ${scriptsDestDir}"
                else
                    msgBox "Changing Scripts Destination Directory\\nFrom: ${scriptsDestDir}\\nTo: ${chosenDir}"
                    scriptsDestDir="${chosenDir}"
                    chosenDir=''
                fi
                ;;
            '2')
                chosenDir=''
                if [ -d "${dotfilesDestDir}" ] && [ -r "${dotfilesDestDir}" ]; then
                    dirPick "${dotfilesDestDir}" 'Choose a dotfiles directory.\nCurrently Viewing: '
                    dirRet=${?}
                elif [ -d "${HOME}" ] && [ -r "${HOME}" ]; then
                    dirPick "${HOME}" 'Choose a dotfiles directory.\nCurrently Viewing: '
                    dirRet=${?}
                else
                    dirPick "/" 'Choose a dotfiles directory.\nCurrently Viewing: '
                    dirRet=${?}
                fi
                if [ "${dirRet}" -eq 1 ]; then
                    msgBox "Canceled\\ndotfiles Directory Unchanged\\nCurrent Value: ${dotfilesDestDir}"
                else
                    msgBox "Changing dotfiles Destination Directory\\nFrom: ${dotfilesDestDir}\\nTo: ${chosenDir}"
                    dotfilesDestDir="${chosenDir}"
                    chosenDir=''
                fi
                ;;
            'D')
                viewSingleFile "${dotfilesDir}"
                ;;
            'S')
                viewSingleFile "${scriptsDir}"
                ;;
            '?')
                showConfig
                ;;
            'C')
                if yesnoBox "Create The Following Directories?\\n(If They Don't Exist)\\n\\n${dotfilesDestDir}\\n${scriptsDestDir}"; then
                    msgBox "Would Create Directories\\nBut Not Yet Implimented"
                fi
                ;;
            '<')
                return 0
                ;;
        esac
        optionsMenuReturn='0'
    done
}

mainMenu(){
    menuSelection="0"
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(${tuiBin} \
            --backtitle "Setup${titleAdditions}" \
            --menu \
                "Automated Setup Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
                "1" "Choose scripts to copy to scripts dir" \
                "2" "Choose dotfiles to copy to dotfiles dir" \
                "-" "" \
                "B" "Bulk Copy Actions" \
                "-" "" \
                "C" "Configuration Options" \
                "?" "Show Current Config" \
                "-" "" \
                "Q" "Quit" \
            2>&1 1>&3); then return 1; fi
    done
    mainMenuReturn="${menuSelection}"
    return 0
}

bulkMenu(){
    menuSelection='0'
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(${tuiBin} \
            --backtitle "Setup${titleAdditions}" \
            --cancel-button "Main Menu" \
            --menu \
                "Bulk Copy Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
            "1" "Copy ALL scripts to scripts dir" \
            "2" "Copy ALL dotfiles to dotfiles dir" \
            "3" "Copy ALL dotfiles (sans .profile) to dotfiles dir" \
            "-" "" \
            "<" "Return to Main Menu" \
            2>&1 1>&3); then return 1; fi
        case "${menuSelection}" in
            '1')
                if ! yesnoBox "Ready to copy ALL included scripts\\n  to the scripts dir?"; then
                    menuSelection='0'
                fi
                ;;
            '2')
                if ! yesnoBox "Ready to copy ALL included dotfiles\\n  to the dotfiles dir?"; then
                    menuSelection='0'
                fi
                ;;
            '3')
                if ! yesnoBox "Ready to copy ALL included dotfiles\\n(excluding .profile)\\n  to the dotfiles dir?"; then
                    menuSelection='0'
                fi
                ;;
        esac
    done
    bulkMenuReturn="${menuSelection}"
    return 0
}

optionsMenu(){
    menuSelection='0'
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(${tuiBin} \
            --backtitle "Setup${titleAdditions}" \
            --cancel-button "Main Menu" \
            --menu \
                "Configuration Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
            "1" "Set Scripts Destination Directory" \
            "2" "Set Dotfiles Destination Directory" \
            "-" "" \
            "?" "Show Current Config" \
            "C" "Create Missing Directories (Not Implimented)" \
            "-" "" \
            "D" "Preview A Dotfile" \
            "S" "Preview A Script" \
            "-" "" \
            "<" "Return to Main Menu" \
            2>&1 1>&3); then return 1; fi
    done
    optionsMenuReturn="${menuSelection}"
    return 0
}


# Setup Dimensions
configDimensions

# Create fd 3
exec 3>&1

# Used to loop on this, but it's now handled in main itself
# Loop here is therefore redundant
main

# Clear the screen
printf '\033c'

# Get rid of fd 3
exec 3>&-
