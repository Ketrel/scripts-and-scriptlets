#!/bin/sh

# Path Config Options
scriptdir=$( dirname "$(readlink -f "${0}")" )
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"

if [ "${1}" = "--live" ]; then
    liveRun='LIVE'
    titleAdditions=' - Live Run'
    shift
else
    liveRun=''
    titleAdditions=' - Dry Run'
fi
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
mainRC="${rcBase}${tuiBin}"
export DIALOGRC="${mainRC}"
export NEWT_COLORS_FILE="${mainRC}"

# Ensure infoMsg is empty at this point
infoMsg=''

# Set up some colors
cRed=$(tput setaf 1 2>/dev/null || printf '')
cReset=$(tput sgr0  2>/dev/null || printf '')
#cBold=$(tput bold   2>/dev/null || printf '')

# shellcheck source=support_files/functions-global.sh
. "${supportdir}/functions-global.sh"

# shellcheck source=support_files/functions-setup-flow.sh
. "${supportdir}/functions-setup-flow.sh"

# shellcheck source=support_files/functions-setup-menus.sh
. "${supportdir}/functions-setup-menus.sh"

# Setup Dimensions
configDimensions

# Create fd 3
exec 3>&1

# Used to loop on this, but it's now handled in main itself
# Loop here is therefore redundant
main

# Clear the screen
printf '\033c'

# Get rid of fd 3
exec 3>&-
