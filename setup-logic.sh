#!/bin/sh

scriptdir=$(dirname "${0}")
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"
dialogRC="${supportdir}/mainRC-dialog"
newtColorsRC="${supportdir}/mainRC-whiptail"
mainRC="${dialogRC}"
infoMsg=''

# shellcheck source=support_files/functions.sh
. "${supportdir}/functions.sh"

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '')
cReset=$(tput sgr0  2>/dev/null || printf '')
cBold=$(tput bold   2>/dev/null || printf '')

# Ensure dialog is present
if (! checkBinary "dialog") ; then
    echo "Major Failure"
    exit 2
fi 

# Setup Dimensions
configDimensions

# Ensure infoMsg is empty at this point
infoMsg=''

# Create fd 3
exec 3>&1

ml=0
while [ ${ml} -eq 0 ]; do
    main
    ml=${?}
done 
printf '\033c'

# Get rid of fd 3
exec 3>&-
