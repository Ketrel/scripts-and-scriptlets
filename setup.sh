#!/bin/sh

# Path Config Options
scriptdir=$( dirname "$(readlink -f "${0}")" )
supportdir="${scriptdir}/support_files"
scriptsDir="${scriptdir}/shell"
dotfilesDir="${scriptdir}/dotfiles"

# Setup variables and defaults
liveRun=''
titleAdditions=' - Dry Run'
scriptsDestDir="${HOME}/Scripts"
dotfilesDestDir="${HOME}"

if command -v whiptail 1>/dev/null 2>&1 ; then
    tuiBin='whiptail'
elif command -v dialog 1>/dev/null 2>&1; then
    tuiBin='dialog'
else
    printf 'Either Whiptail or Dialog is required\nBut neither was found.\n'
    exit 3
fi

# Loop through args
while [ -n "${1}" ]; do
    case "${1}" in
        '--help'|'-h')
            # If first arg is --help or -h, print help and exit
            printf '%b\n\n' "\
 Setup Script

 Depends On
   tput (Optional)
   highlight (Optional for some functionality)
   dialog or whiptail (At least one is required)

 Usage: $( basename "$(readlink -f "${0}")" ) <options>

 Arguments
   --help, ,-h
     print this help message and exit

   --live
     Actually make changes, defaults to dry run otherwise

   --dialog
     Forces use of dialog
     (script will fail if dialog is not present)"
            exit 0
            ;;
        '--live')
            liveRun='LIVE'
            titleAdditions=' - Live Run'
            shift
            ;;
        '--dialog')
            if command -v dialog 1>/dev/null 2>&1; then
                tuiBin='dialog'
            else
                printf 'Dialog switch used, but dialog not present in path.\n'
                exit 3
            fi
            shift
            ;;
        *)
            printf 'Bad/Unsupported Switches Provided.  Please double check usage.\n'
            exit 3
    esac
done

rcBase="${supportdir}/mainRC-"
mainRC="$(readlink -f "${rcBase}${tuiBin}")"
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

if ! checkCrippledUtils; then
    printf 'Busybox or Toybox is providing one or more utilities on which this script depends.\n'
    printf ' To ensure there is no unintended behavior, this script will now exit.\n'
    printf '\n  Required Utilities:\n  - find\n  - sed\n  - grep\n'
    exit 127
fi

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
