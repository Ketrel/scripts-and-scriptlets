#!/bin/sh

scriptdir=$(dirname "${0}")
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"
tuiBin='dialog'
rcBase="${supportdir}/mainRC-"
#dialogRC="${supportdir}/mainRC-dialog"
#newtColorsRC="${supportdir}/mainRC-whiptail"
mainRC="${rcBase}${tuiBin}"
infoMsg=''

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '')
cReset=$(tput sgr0  2>/dev/null || printf '')
cBold=$(tput bold   2>/dev/null || printf '')

# shellcheck source=support_files/functions-dialog.sh
# shellcheck source=support_files/functions-whiptail.sh
. "${supportdir}/functions-${tuiBin}.sh"

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

#ml=0
#while [ ${ml} -eq 0 ]; do
#    main
#    ml=${?}
#done 
while main ; do
    # do nothing, I just want to loop on the return code of main
    :
done
printf '\033c'

# Get rid of fd 3
exec 3>&-
