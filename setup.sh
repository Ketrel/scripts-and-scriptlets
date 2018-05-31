#!/bin/sh

scriptdir=$(dirname ${0})
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"
mainRC="${supportdir}/mainRC"
dialogRC="${supportdir}/dialogRC"

checkBinary()
{
    if [ "${1}" = "tput" ]; then
        if [ $(which tput) ]; then
            tputBin=$(which tput)
            return 0
        else
            tputBin=':'
            return 1
        fi
    elif [ $(which ${1}) ]; then
        return 0        
    else
        printf "$($tputBin setaf 1)%b$($tputBin sgr0)\n" "Error: Specifcied Binary '${1}' Not Found." 
        if [ "${2}" = "optional" ]; then
            printf "$($tputBin setaf 1)%b$($tputBin sgr0)\n\n" "----\nWhile the script will work without it, functionality may be limited." 
        else
            printf "$($tputBin setaf 1)%b$($tputBin sgr0)\n\n" "----\nThis binary is required for this script to function.\n If the binary is present on our machine,\n please ensure it's accessible via your PATH." 
        fi
        return 1
    fi
}
configDimensions()
{
    if [ "${tputBin}" = ":" ]; then
        #80x25 is the safe assumption
        mainWidth=70
        mainHeight=15
        menuHeight=12
        return 0
    fi
    mainWidth=$(( $(${tputBin} cols) / 10 * 8 ))
    mainHeight=$(( $(${tputBin} lines) / 10 * 8 ))
    menuHeight=$(( ${mainHeight} - 3 ))
}
msgBox()
{
    if [ -n "${1}" ]; then
        DIALOGRC="${dialogRC}" dialog --msgbox "${1}" ${mainHeight} ${mainWidth}
    fi
}
generateSelect()
{
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        echo "Unrecoverable Script Failure\nNeeds Debugging"
        exit 5
    fi
    cd ${1}
    fileList=$(find . -type f -exec sh -c 'printf "%s\n" "$(basename {})"' \; | sort)
    cd - 1>/dev/null
    i=0
    checkList=''
    while read -r line
    do
        i=$(($i+1))
        checkList="${checkList}\"${i}\" \"${line}\" \"off\" "
    done <<EOF
${fileList}
EOF
    results=$(eval "DIALOGRC="${mainRC}" dialog --backtitle 'Setup' \
            --title 'File Select' \
            --checklist \"Select Files\" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            ${checkList} \
            2>&1 1>&3")
    clear
    if [ -n "${results}" ]; then
        chosen=$(echo "${results}" | sed -e 's/ /\n/g')
        i=1
            
        # Blank out infoMsg for fresh use
        infoMsg=''
        while read -r line 
        do
            if grep -E "\\b${i}\\b" >/dev/null <<EOF
${results}
EOF
            then
                infoMsg="${infoMsg}Copied "${line}" to ${2}\n"
                infoMsg="${infoMsg}  DRY RUN: cp \"${1}/${line}\" \"${2}/${line}\"\n"
            fi
            i=$(($i+1))
        done <<EOFF
${fileList}
EOFF
    else
        printf "$($tputBin setaf 1)%b$(${tputBin} sgr0)\n" "Error: No Files Selected"
        exit 1
    fi
}

# Make sure 'which' exists before proceding
which which || exit 7

# Set up the tputBin variable
if [ -z "${tputBin}" ] ; then
    checkBinary "tput"
fi

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
            "Automated Setup Options\n---\n" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            "1" "Copy Scripts To Scripts Dir" \
            "2" "Copy Specific Scripts To Scripts Dir" \
            "3" "Copy Dotfiles To Dotfiles Dir" \
            "4" "Copy Dotfiles (Except .profile) Dotfiles Dir" \
            "5" "Copy Specific Dotfiles To Dotfiles Dir" \
            "-" "----------" \
            "0" "Setup Paths (Not Implimented)" \
            "?" "Show Current Config" \
        2>&1 1>&3)
        #In the menu below\n  \$HOME refers to \"${HOME}\"" \

    if [ "${menuSelection}" = "?" ]; then
        msgBox "Current Config\n----------\n\nDestination for scripts:\n  ${scriptsDestDir}\n\nDestination for dotfiles:\n  ${dotfilesDestDir}"
    fi

    menuConfigSelect="x"
    while [ "${menuSelection}" = "0" ] && [ -n "${menuConfigSelect}" ] && [ ! "${menuConfigSelect}" = "0" ]; do
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
            2>&1 1>&3)

        case "${menuConfigSelect}" in
            "1")
                scriptsDestDirTemp=$(DIALOGRC=${mainRC} dialog \
                    --backtitle "Setup" \
                    --clear \
                    --dselect \
                        "${HOME}/" \
                        ${mainHeight} \
                        ${mainWidth} \
                    2>&1 1>&3)
                if [ -n "${scriptsDestDirTemp}" ] && [ -d ${scriptsDestDirTemp} ]; then
                    msgBox "Scripts Destination Changed.\n Was: ${scriptsDestDir}\n Is Now: ${scriptsDestDirTemp}"
                    scriptsDestDir=${scriptsDestDirTemp%/}
                fi
            ;;
            "2")
                dotfilesDestDirTemp=$(DIALOGRC=${mainRC} dialog \
                    --backtitle "Setup" \
                    --clear \
                    --dselect \
                        "${HOME}/" \
                        ${mainHeight} \
                        ${mainWidth} \
                    2>&1 1>&3)
                if [ -n "${dotfilesDestDirTemp}" ] && [ -d ${dotfilesDestTempDir} ]; then
                    msgBox "Scripts Destination Changed.\n Was: ${dotfilesDestDir}\n Is Now: ${dotfilesDestDirTemp}"
                    dotfilesDestDir=${dotfilesDestDirTemp%/}
                fi
            ;;
        esac
    done
done
${tputBin} clear
case "${menuSelection}" in
    '1')
        infoMsg="${infoMsg}Copying included scripts to \"${scriptsDestDir}\""
        infoMsg="${infoMsg}\n    Dry Run: Not Doing Anything for Real"
        
        # find ${scriptsDir} -type f -exec echo cp -t \"${scriptsDestDir}\" {} +
    ;;
    '2')
        infoMsg=''
        generateSelect "${scriptsDir}" "${scriptsDestDir}"
    ;;
    '3')
        infoMsg="${infoMsg}Copying dotfiles to: \"${dotfilesDestDir}\""
        infoMsg="${infoMsg}\n    Dry Run: Not Doing Anything for Real"

        # find ${scriptisDir} -type f -exec echo cp -t \"${HOME}/\" {} +
    ;; 
    '4')
        infoMsg="${infoMsg}Copying dotfiles (excuding .profile) to: \"${dotfilesDestDir}\""
        infoMsg="${infoMsg}\n    Dry Run: Not Doing Anything for Real"
        
        # find ${dotfilesDir} -type f ! -name ".profile" -exec echo cp -t \"${dotfilesDestDir}/\" {} +
    ;;
    '5')
        infoMsg=''
        generateSelect "${dotfilesDir}" "${dotfilesDestDir}"
    ;; 
esac
if [ -n "${infoMsg}" ]; then
    DIALOGRC="${dialogRC}" dialog  --backtitle "Setup Results" --title "Results" --msgbox "$infoMsg" ${mainHeight} ${mainWidth}
    clear
fi
exec 3>&-