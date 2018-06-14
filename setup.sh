#!/bin/sh

if [ "${1}" = "--live" ]; then
    liveRun='LIVE'
    titleAdditions=' - Live Run'
    shift
else
    liveRun=''
    titleAdditions=' - Dry Run'
fi
scriptdir=$( dirname "$(readlink -f "${0}")" )
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"
if command -v whiptail 1>/dev/null 2>&1 && [ ! "${1}" = "--dialog" ] ; then
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
export DIALOGRC="${mainRC}"
export NEWT_COLORS_FILE="${mainRC}"

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '')
cReset=$(tput sgr0  2>/dev/null || printf '')
#cBold=$(tput bold   2>/dev/null || printf '')

# shellcheck source=support_files/functions-global.sh
. "${supportdir}/functions-global.sh"

# Only the one, it checks the liveRun variable itself
# shellcheck source=support_files/functions-setup.sh
. "${supportdir}/functions-setup.sh"

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
