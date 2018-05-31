#!/bin/sh

scriptdir=$(dirname "${0}")
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"
mainRC="${supportdir}/mainRC"
dialogRC="${supportdir}/dialogRC"

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
    menuHeight=$(( mainHeight - 3 ))
}
msgBox()
{
    if [ -n "${1}" ]; then
        DIALOGRC="${dialogRC}" dialog --msgbox "${1}" ${mainHeight} ${mainWidth}
    fi
}
yesnoBox()
{
    if [ -n "${1}" ]; then
        DIALOGRC="${dialogRC}" dialog --yesno "${1}" ${mainHeight} ${mainWidth}
        result=$?
        return ${result}
    fi
}
generateSelect()
{
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        printf "%b\\n" "Unrecoverable Script Failure\\nNeeds Debugging"
        exit 5
    fi
    cd "${1}" || exit 1
    fileList=$(find . -type f -exec sh -c 'printf "%s\n" "$(basename "${1}")"' sh {} \; | sort)
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
    results=$(eval "DIALOGRC=\"${mainRC}\" dialog --backtitle 'Setup' \
            --title 'File Select' \
            --checklist \"Select Files\" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            ${checkList} \
            2>&1 1>&3")
    printf '\033c'
    if [ -n "${results}" ]; then
        chosen=$(echo "${results}" | sed -e 's/ /\n/g')
        i=1
            
        # Blank out infoMsg for fresh use
        infoMsg=''
        while read -r line 
        do
            if grep -E "\\b${i}\\b" >/dev/null <<EOF
${chosen}
EOF
            then
                infoMsg="${infoMsg}Copied \"${line}\" to ${2}\\n"
                cp "${1}/${line}" "${2}/${line}" || { printf "${cRed}%b${cReset}\\n" "Error Copying Files"; exit 41; }
            fi
            i=$((i+1))
        done <<EOFF
${fileList}
EOFF
    else
        printf "${cRed}%b${cReset}\\n" "Error: No Files Selected"
        exit 40 
    fi
}

# Make sure 'which' exists before proceding
# which which || exit 44
# not needed if using command -v

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '' )
cReset=$(tput sgr0 2>/dev/null || printf '' )
cBold=$(tput bold 2>/dev/null || printf '' )

# Ensure dialog is present
if ! checkBinary "dialog" ; then
    echo "Major Failure"
    exit 2
fi 

# Setup Dimensions
configDimensions

# Ensure infoMsg is empty at this point
infoMsg=''

# Create fd 3
exec 3>&1

# Generate Menu
menuSelection="0"
while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ] || [ "${menuSelection}" = "?" ]; do
    menuSelection=$(DIALOGRC="${mainRC}" \
        dialog \
        --backtitle "Setup" \
        --clear \
        --menu \
            "Automated Setup Options\\n---\\n" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            "1" "Copy Scripts To Scripts Dir" \
            "2" "Copy Specific Scripts To Scripts Dir" \
            "-" "----------" \
            "3" "Copy Dotfiles To Dotfiles Dir" \
            "4" "Copy Dotfiles (Except .profile) Dotfiles Dir" \
            "5" "Copy Specific Dotfiles To Dotfiles Dir" \
            "-" "----------" \
            "0" "Configuration Options" \
            "?" "Show Current Config" \
            "-" "----------" \
            "Q" "Quit" \
        2>&1 1>&3)
        #In the menu below\n  \$HOME refers to \"${HOME}\"" \

        case "$menuSelection" in
            '?')
                msgBox "Current Config\\n----------\\n\\nDestination for scripts:\\n  ${scriptsDestDir}\\n\\nDestination for dotfiles:\\n  ${dotfilesDestDir}"
            ;;
            '0')
                menuConfigSelect="x"
                while [ -n "${menuConfigSelect}" ] && [ ! "${menuConfigSelect}" = "0" ]; do
                    menuConfigSelect=$(DIALOGRC="${mainRC}" \
                        dialog \
                        --backtitle "Setup" \
                        --clear \
                        --menu \
                            "Configuration Options" \
                            ${mainHeight} \
                            ${mainWidth} \
                            ${menuHeight} \
                        "1" "Set Scripts Destination Directory" \
                        "2" "Set Dotfiles Destination Directory" \
                        "-" "----------" \
                        "0" "Return" \
                        "?" "Show Current Config" \
                        "C" "Create Missing Directories (Not Implimented)" \
                        "-" "----------" \
                        "Q" "Quit" \
                        2>&1 1>&3)

                    case "${menuConfigSelect}" in
                        '1')
                            tempDir=$(DIALOGRC=${mainRC} dialog \
                                --backtitle "Setup" \
                                --clear \
                                --dselect \
                                    "${HOME}/" \
                                    ${mainHeight} \
                                    ${mainWidth} \
                                2>&1 1>&3)
                            # && [ -d ${tempDir} ]
                            if [ -n "${tempDir}" ] && [ ! "${tempDir}" = "/" ]; then
                                msgBox "Scripts Destination Changed.\\n Was: ${scriptsDestDir}\\n Is Now: ${tempDir}"
                                scriptsDestDir=${tempDir%/}
                            fi
                        ;;
                        '2')
                            tempDir=$(DIALOGRC=${mainRC} dialog \
                                --backtitle "Setup" \
                                --clear \
                                --dselect \
                                    "${HOME}/" \
                                    ${mainHeight} \
                                    ${mainWidth} \
                                2>&1 1>&3)
                            # && [ -d ${tempDir} ]
                            if [ -n "${tempDir}" ] && [ ! "${tempDir}" = "/" ]; then
                                msgBox "Dotfiles Destination Changed.\\n Was: ${dotfilesDestDir}\\n Is Now: ${tempDir}"
                                dotfilesDestDir=${tempDir%/}
                            fi
                        ;;
                        '?')
                            msgBox "Current Config\\n----------\\n\\nDestination for scripts:\\n  ${scriptsDestDir}\\n\\nDestination for dotfiles:\\n  ${dotfilesDestDir}"
                        ;;
                        'C')
                            if yesnoBox "Create The Following Directories?\\n(If They Don't Exist)\\n\\n${dotfilesDestDir}\\n${scriptsDestDir}"; then
                                msgBox "Would Create Directories"
                            fi 
                        ;;
                        'Q')
                            printf '\033c'
                            exit 0
                        ;;
                    esac
                done
            ;;
            'Q')
                printf '\033c'
                exit 0
            ;;
        esac
done
case "${menuSelection}" in
    '1')
        infoMsg="${infoMsg}Copying included scripts to \"${scriptsDestDir}\""
        
        find "${scriptsDir}" -type f -exec cp {} "${scriptsDestDir}/" \;
    ;;
    '2')
        infoMsg=''
        generateSelect "${scriptsDir}" "${scriptsDestDir}"
    ;;
    '3')
        infoMsg="${infoMsg}Copying dotfiles to: \"${dotfilesDestDir}\""

        find "${scriptsDir}" -type f -exec cp {} "${dotfilesDestDir}/" \;
    ;; 
    '4')
        infoMsg="${infoMsg}Copying dotfiles (excuding .profile) to: \"${dotfilesDestDir}\""
        
        find "${dotfilesDir}" -type f ! -name ".profile" -exec cp {} "${dotfilesDestDir}/" \;
    ;;
    '5')
        infoMsg=''
        generateSelect "${dotfilesDir}" "${dotfilesDestDir}"
    ;; 
esac
if [ -n "${infoMsg}" ]; then
    DIALOGRC="${dialogRC}" dialog  --backtitle "Setup Results" --title "Results" --msgbox "$infoMsg" ${mainHeight} ${mainWidth}
    printf '\033c'
fi
exec 3>&-
