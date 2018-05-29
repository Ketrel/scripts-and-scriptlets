#!/bin/sh
scriptdir=$(dirname ${0})
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

# Generate Menu
exec 3>&1
menuSelection=$(\
dialog \
    --backtitle "Setup" \
    --clear \
    --menu \
    "Automated Setup Options\n---\n\$HOME=${HOME}" \
    ${mainHeight} \
    ${mainWidth} \
    ${menuHeight} \
    "1" "Copy Scripts To:  \$HOME/Scripts/<file(s)>" \
    "2" "Copy dotfiles To: \$HOME/<file(s)>" \
    "3" "Copy dotfiles (Except .profile) To: \$HOME/<file(s)>" \
    "4" "(Currently Unused Option, Does Nothing)" \
    "5" "(Currently Unused Option, Does Nothing)" \
    2>&1 1>&3)
${tputBin} clear
# if [ ! -z "${menuSelection}" ]; then
#     echo "Selected: ${menuSelection}"
# else
#     echo "Canceled or Escaped Out of Menu"
# fi
case ${menuSelection} in
    1)
        printf "$(${tputBin} setaf 2)%b$(${tputBin} sgr0)\n" \
            "Copying included scripts to \"${HOME}/Scripts\""
        echo "Dry Run: Not Doing Anything for Real"
        echo 
        # find ${scriptdir}/shell -type f -exec echo cp -t \"${HOME}/Scripts\" {} +
    ;;
    2)
        printf "$(${tputBin} setaf 2)%b$(${tputBin} sgr0)\n" \
            "Copying dotfiles to: \"${HOME}\""
        echo "Dry Run: Not Doing Anything for Real"
        echo
        # find ${scriptdir}/dotfiles -type f -exec echo cp -t \"${HOME}/\" {} +
    ;; 
    3)
        printf "$(${tputBin} setaf 2)%b$(${tputBin} sgr0)\n" \
            "Copying dotfiles (excuding .profile) to: \"${HOME}\""
        echo "Dry Run: Not Doing Anything for Real"
        echo
        find ${scriptdir}/dotfiles -type f ! -name ".profile" -exec echo cp -t \"${HOME}/\" {} +
    ;; 
    4)
        results=$(dialog --backtitle "Test" --checklist "Select Test" \
            ${mainHeight} \
            ${mainWidth} \
            ${menuHeight} \
            "1" "Item 1" "off" \
            "2" "Item 2" "off" \
            "3" "Item 3" "on" \
            "4" "Item 4" "off" \
            2>&1 1>&3)
        clear
        echo "--${results}--"
    ;;
esac

exec 3>&-
