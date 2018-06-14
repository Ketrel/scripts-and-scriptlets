#!/bin/sh

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
            # '1')
                # mainMenuAgain='1'
                # copyFiles "${scriptsDir}" "${scriptsDestDir}" "scripts"
                # ;;
            # '2')
                # mainMenuAgain='1'
                # copySelectedFiles "${scriptsDir}" "${scriptsDestDir}" "scripts"
                # if [ ${?} -eq 1 ]; then
                    # return 0
                # fi
                # ;;
            # '3')
                # mainMenuAgain='1'
                # copyFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files"
                # ;;
            # '4')
                # mainMenuAgain='1'
                # copyFiles "${dotfilesDir}" "${dotfilesDestDir}" "dot files (excluding .profile)" "noprofile"
                # ;;
            # '5')
                # mainMenuAgain='1'
                # copySelectedFiles "${dotfilesDir}" "${dotfilesDestDir}"
                # if [ ${?} -eq 1 ]; then
                    # return 0
                # fi
                # ;;
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
    while [ "${bulkMenuReturn}" = "0" ]; do
        bulkMenu
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
    while [ "${optionsMenuReturn}" = "0" ]; do
        optionsMenu
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
            '<')
                return 0
                ;;
        esac
        optionsMenuReturn='0'
    done
}