#!/bin/sh

main(){
    menuReturn='0'
    infoMsg=''

    while [ "${menuReturn}" = "0" ]; do
        menuAgain='1'

        if ! mainMenu; then
            printf -- '---You Broke It---\n'
            exit 1
        fi

        case "${menuReturn}" in
            '1')
                menuAgain='1'
                copyFiles "${scriptsDir}" "${scriptsDestDir}" "scripts"
                ;;
            '2')
                menuAgain='1'
                copySelectedFiles "${scriptsDir}" "${scriptsDestDir}" "scripts"
                if [ ${?} -eq 1 ]; then
                    return 0
                fi
                ;;
            '3')
                menuAgain='1'
                copyFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files"
                ;;
            '4')
                menuAgain='1'
                copyFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files (excluding .profile)" "noprofile"
                ;;
            '5')
                menuAgain='1'
                copySelectedFiles "${dotfilesDir}" "${dotfilesDestDir}"
                if [ ${?} -eq 1 ]; then
                    return 0
                fi
                ;;
            'C')
                menuAgain='0'
                menuReturn='0'
                optionsMenu
                ;;
            '?')
                menuAgain='0'
                menuReturn='0'
                showConfig
                ;;
            'Q')
                printf '\033c'
                exit 0
                ;;
        esac

        if [ "${menuAgain}" -eq "1" ]; then
            if NEWT_COLORS_FILE="${mainRC}" DIALOGRC="${mainRC}" ${tuiBin} --backtitle "Setup" --title "Continue" --yesno "Finished\\nRun More Tasks?\\n\\nActions Takeni This Round:\\n${infoMsg}" ${mainHeight} ${mainWidth}; then
                infoMsg=''
                menuReturn='0'
            fi
        fi
    done

    exit 8
    if [ -n "${infoMsg}" ]; then
        NEWT_COLORS_FILE="${mainRC}" DIALOGRC="${mainRC}" ${tuiBin}  --backtitle "Setup" --title "Results" --msgbox "$infoMsg" ${mainHeight} ${mainWidth}
        infoMsg=''
    fi
}

mainMenu(){
    menuSelection="0"
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(NEWT_COLORS_FILE="${mainRC}" DIALOGRC="${mainRC}" \
            ${tuiBin} \
            --backtitle "Setup" \
            --clear \
            --menu \
                "Automated Setup Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
                "1" "Copy Scripts To Scripts Dir" \
                "2" "Copy Specific Scripts To Scripts Dir" \
                "-" "" \
                "3" "Copy Dotfiles To Dotfiles Dir" \
                "4" "Copy Dotfiles (Except .profile) Dotfiles Dir" \
                "5" "Copy Specific Dotfiles To Dotfiles Dir" \
                "-" "" \
                "C" "Configuration Options" \
                "?" "Show Current Config" \
                "-" "" \
                "Q" "Quit" \
            2>&1 1>&3); then return 1; fi
    done
    menuReturn="${menuSelection}"
    return 0
}

optionsMenu(){
    menuConfigSelect="x"
    while [ -n "${menuConfigSelect}" ] && [ ! "${menuConfigSelect}" = "<" ]; do
        menuConfigSelect=$(NEWT_COLORS_FILE="${mainRC}" DIALOGRC="${mainRC}" \
            ${tuiBin} \
            --backtitle "Setup" \
            --clear \
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
            "<" "Return" \
            2>&1 1>&3)

        case "${menuConfigSelect}" in
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
                selectSingleFile "${dotfilesDir}"
                ;;
            'S')
                selectSingleFile "${scriptsDir}"
                ;;
            '?')
                showConfig
                ;;
            'C')
                if yesnoBox "Create The Following Directories?\\n(If They Don't Exist)\\n\\n${dotfilesDestDir}\\n${scriptsDestDir}"; then
                    msgBox "Would Create Directories\\nBut Not Yet Implimented"
                fi
                ;;
        esac
    done
    return 0
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
    infoMsg="${infoMsg}\\n    Dry Run: Not Doing Anything for Real"

    # if [ "${4}" = "noprofile" ]; then
        # find "${1}" -type f ! -name ".profile" -exec cp {} "${2}/" \;
    # else
        # find "${1}" -type f -exec cp {} "${2}/" \;
    # fi
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
    fileList=$(find . -type f ! -name '*"*' -exec sh -c 'printf "%s\n" "$(basename "${1}")"' sh {} \; | sort)
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
    results=$(eval "NEWT_COLORS_FILE=\"${mainRC}\" DIALOGRC=\"${mainRC}\" ${tuiBin} --backtitle 'Setup' \
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
                infoMsg="${infoMsg}\\nCopied \"${line}\" to ${2}"
                infoMsg="${infoMsg}\\n  DRY RUN: cp \"${1}/${line}\" \"${2}/${line}\""
                # cp "${1}/${line}" "${2}/${line}" || { printf "${cRed}%b${cReset}\\n" "Error Copying Files"; exit 41; }
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

selectSingleFile(){
    if [ -z "${1}" ]; then
        printf '%b\n' "Pretty Bad Error\\nScript Needs Debugging"
        exit 6
    fi
    cd "${1}" || exit 1
    _ffileList=''
    _ffileList=$(find . -type f ! -name '*"*' -exec sh -c 'printf "\"%s\" OFF\n" "${1}"' sh {} \; | sed -e 's/\.\///g' | LC_ALL=C sort -g | tr '\n' ' ')
#    printf '%b\n' "${_ffileList}"
#    exit 88
    if [ -n "${_ffileList}" ]; then
        if _fselectedFile=$(eval "NEWT_COLORS_FILE=\"${mainRC}\" DIALOGRC=\"${mainRC}\" ${tuiBin} --backtitle 'Setup' \
        --title 'File Select' \
        --noitem \
        --radiolist \"Select A File\" \
        ${mainHeight} \
        ${mainWidth} \
        ${menuHeight} \
        ${_ffileList} \
        2>&1 1>&3"); then
            if command -v highlight 1>/dev/null 2>&1; then
                ( highlight -O ansi "${_fselectedFile}" >2/dev/null || highlight -O ansi -S sh "${_fselectedFile}" ) | less -S -r -# 2
            else
                less -S -r -# 2 "${_fselectedFile}"
            fi
        fi
    fi
}
