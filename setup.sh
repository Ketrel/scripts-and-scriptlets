#!/bin/sh

scriptdir=$(dirname ${0})
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"

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
generateSelect()
{
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        echo "Script Failure\nNeeds Debugging"
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
    results=$(eval "DIALOGRC="${supportdir}/mainRC" dialog --backtitle 'Setup' \
            --title 'File Select' \
            --checklist \"Select DotFiles To Copy\" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            ${checkList} \
            2>&1 1>&3")
    clear
    if [ ! -z "${results}" ]; then
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

# Generate Menu
exec 3>&1
menuSelection="0"
while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
    menuSelection=$(DIALOGRC="${supportdir}/mainRC" \
        dialog \
        --backtitle "Setup" \
        --clear \
        --menu \
        "Automated Setup Options\n---\nIn the menu below\n  \$HOME refers to \"${HOME}\"" \
        ${mainHeight} \
        ${mainWidth} \
        ${menuHeight} \
        "1" "Copy Scripts To:   \$HOME/Scripts/<file(s)>" \
        "2" "Copy dotfiles To:  \$HOME/<file(s)>" \
        "3" "Copy dotfiles (Except .profile) To: \$HOME/<file(s)>" \
        "4" "Copy specific dotfiles To: \$HOME/<file(s)>" \
        "5" "Copy specific scripts To:  \$HOME/Scripts/<file(s)>" \
        "-" "----------" \
        "0" "Setup Paths (Not Implimented)" \
        2>&1 1>&3)

    menuConfigSelect="x"
    while [ "${menuSelection}" = "0" ] && [ ! -z "${menuConfigSelect}" ] && [ ! "${menuConfigSelect}" = "0" ]; do
        menuConfigSelect=$(DIALOGRC="${supportdir}/mainRC" \
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
    done
done
${tputBin} clear
case ${menuSelection} in
    1)
        infoMsg="${infoMsg}Copying included scripts to \"${HOME}/Scripts\""
        infoMsg="${infoMsg}\n    Dry Run: Not Doing Anything for Real"
        
        # find ${scriptdir}/shell -type f -exec echo cp -t \"${HOME}/Scripts\" {} +
    ;;
    2)
        infoMsg="${infoMsg}Copying dotfiles to: \"${HOME}\""
        infoMsg="${infoMsg}\n    Dry Run: Not Doing Anything for Real"

        # find ${scriptdir}/dotfiles -type f -exec echo cp -t \"${HOME}/\" {} +
    ;; 
    3)
        infoMsg="${infoMsg}Copying dotfiles (excuding .profile) to: \"${HOME}\""
        infoMsg="${infoMsg}\n    Dry Run: Not Doing Anything for Real"
        
        # find ${scriptdir}/dotfiles -type f ! -name ".profile" -exec echo cp -t \"${HOME}/\" {} +
    ;;
    4)
        infoMsg=''
        generateSelect "${dotfilesDir}" "${HOME}"
    ;; 
    5)
        infoMsg=''
        generateSelect "${scriptsDir}" "${HOME}/Scripts"

    ;;
esac
if [ ! -z "${infoMsg}" ]; then
    DIALOGRC="${supportdir}/dialogMsgBox" dialog  --backtitle "Setup Results" --title "Results" --msgbox "$infoMsg" ${mainHeight} ${mainWidth}
fi
exec 3>&-
