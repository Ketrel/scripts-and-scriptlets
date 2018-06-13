#!/bin/sh
    
scriptdir=$( dirname "$(readlink -f "${0}")" )
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"
if command -v whiptail 1>/dev/null 2>&1; then
    tuiBin='whiptail'
elif command -v dialog 1>/dev/null 2>&1; then
    tuiBin='dialog'
else
    printf 'Either Whiptail or Dialog is required\nBut neither was found.\n'
    exit 3
fi
rcBase="${supportdir}/mainRC-"
#dialogRC="${supportdir}/mainRC-dialog"
#newtColorsRC="${supportdir}/mainRC-whiptail"
mainRC="${rcBase}${tuiBin}"
infoMsg=''

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '')
cReset=$(tput sgr0  2>/dev/null || printf '')
#cBold=$(tput bold   2>/dev/null || printf '')

# shellcheck source=support_files/functions-global.sh
. "${supportdir}/functions-global.sh"

# Check for live switch and if set, use live functions
if [ "${1}" = "--live" ]; then
    # shellcheck source=support_files/functions-setup-live.sh
    . "${supportdir}/functions-setup-live.sh"
else
    # shellcheck source=support_files/functions-setup.sh
    . "${supportdir}/functions-setup.sh"
fi

# Setup Dimensions
configDimensions

# Ensure infoMsg is empty at this point
infoMsg=''

# Create fd 3
exec 3>&1

while main ; do
    # do nothing, I just want to loop on the return code of main
    :
done
printf '\033c'

# Get rid of fd 3
exec 3>&-
