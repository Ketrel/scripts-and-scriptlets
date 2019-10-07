#!/bin/sh

# This is the command that will be used to run xscreensaver
#   Note: It will be run in the background
xsc_command="xscreensaver -no-splash"

xsc_showhelp() {
    printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
        'Starts or stops xscreensaver.' \
        ' --start, --enable       start xscreensaver' \
        ' --stop,  --disable      kill xscreensaver' \
        ' --cenable               enable xscreensaver in user'"'"'s .xscreensaver file' \
        ' --cdisable              disable xscreensaver in user'"'"'s .xscreensaver file' \
        ' --toggle                not implemented' \
        ' --status                show the current status and exit'
}

xsc_ascii=$(cat << 'EOF'
__  __                                                      
\ \/ /___  ___ _ __ ___  ___ _ __  ___  __ ___   _____ _ __ 
 \  // __|/ __| '__/ _ \/ _ \ '_ \/ __|/ _` \ \ / / _ \ '__|
 /  \\__ \ (__| | |  __/  __/ | | \__ \ (_| |\ V /  __/ |   
/_/\_\___/\___|_|  \___|\___|_| |_|___/\__,_| \_/ \___|_|   
                                                            
            ____            _             _ 
           / ___|___  _ __ | |_ _ __ ___ | |
          | |   / _ \| '_ \| __| '__/ _ \| |
          | |__| (_) | | | | |_| | | (_) | |
           \____\___/|_| |_|\__|_|  \___/|_|
EOF
)

xsc_ascii_art() {
    printf '%s' "${xsc_ascii}"
}

xsc_exec() {
    if [ "${xsc_state}" = "Running" ]; then
        printf 'xscreensaver was detected to be running; stopping\n'
        ${xsc_command} &
    else
        printf 'xscreensaver was not detected to be running; starting\n'
        pkill -U "${xsc_user}" xscreensaver
    fi
}

if ! command -v xscreensaver 2>/dev/null 1>&2; then
    printf "%s\n" "xscreensaver binary, not found in PATH.  This tool will not function."
    exit 1
fi

xsc_user="$(id -u)"

if ! xsc_pid="$(pgrep -U ${xsc_user} xscreensaver 1>/dev/null 2>&1)"; then
    xsc_state="Not Running"
else
    xsc_state="Running"
fi

if [ -z "${1}" ]; then
    xsc_ascii_art
    printf '\n\nPlease Run with the --help switch for usage information\n\n'
    exit 0
fi

case "${1}" in
    '--help'|'-h')
        xsc_showhelp
        exit 0
    ;;
    '--start'|'--enable')
        if [ "${xsc_state}" = "Running" ]; then
            printf 'xscreensaver is already running.\n'
            exit
        else
            printf 'Starting xscreensaver.\n'
            ${xsc_command} &
        fi
    ;;
    '--stop'|'--disable')
        if [ "${xsc_state}" = "Running" ]; then
            printf 'Stopping xscreensaver.\n';
            pkill -U "${xsc_user}" xscreensaver
        else
            printf 'xscreensaver was not detected to be running.\n'
            exit
        fi
    ;;
    '--cenable')
        if [ -w "${HOME}/.xscreensaver" ]; then
            sed -i -e '/^mode/ s/\b[A-Za-z0-9_]\+$/one/' "${HOME}/.xscreensaver"
            printf 'xscreensaver enabled by changing mode to: one\n'
        else
            printf '.xscreensaver file in "%s" not found or not writable.\nNothing was done.\n\n' "${HOME}"
            exit 1
        fi
    ;;
    '--cdisable')
        if [ -w "${HOME}/.xscreensaver" ]; then
            sed -i -e '/^mode/ s/\b[A-Za-z0-9_]\+$/off/' "${HOME}/.xscreensaver" 
            printf 'xscreensaver disabled by changing mode to: off\n'
        else
            printf '.xscreensaver file in "%s" not found or not writable.\nNothing was done.\n\n' "${HOME}"
            exit 1
        fi
    ;;
    '--status')
        printf 'xscreensaver is currently: %s\n' "${xsc_state}"
        exit 0
    ;;
    '--toggle')
        #xsc_exec
        printf '%s\n' 'Not Yet Implemented'
        exit 0
    ;;
    *)
        printf '%s\n\n' 'Invalid Action Specified.  Please refer to help below'
        xsc_showhelp
    ;;
esac

                                            
