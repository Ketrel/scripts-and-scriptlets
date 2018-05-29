#!/bin/sh
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
    "Automated Setup Options" \
    ${mainHeight} \
    ${mainWidth} \
    ${menuHeight} \
    "1" "Copy Scripts To:  '<home>/Scripts/'" \
    "2" "Copy dotfiles To: '<home>/<file>'" \
    2>&1 1>&3)
${tputBin} clear
exec 3>&-
if [ ! -z "${menuSelection}" ]; then
    echo "Selected: ${menuSelection}"
else
    echo "Canceled or Ctrl-C'd Out of Menu"
fi
