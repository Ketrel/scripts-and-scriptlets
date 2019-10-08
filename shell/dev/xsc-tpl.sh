#!/bin/sh

# This is the command that will be used to run xscreensaver
#   Note: It will be run in the background
xsc_command="xscreensaver -no-splash"

xsc_showhelp() {
    printf '%s\n%s\n%s\n%s\n%s\n%s\n' \
        'Starts or stops xscreensaver.' \
        ' --enable                enable xscreensaver in user'"'"'s .xscreensaver file' \
        ' --disable               disable xscreensaver in user'"'"'s .xscreensaver file' \
        ' --set-timeout <m> [h]   set the idle time before xscreensaver activates.' \
        '                         (takes a mandatory minute and optional hour argument)' \
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
    '--enable')
        if [ -w "${HOME}/.xscreensaver" ]; then
            sed -i -e '/^mode/ s/\b[A-Za-z0-9_]\+$/one/' "${HOME}/.xscreensaver"
            printf 'xscreensaver enabled by changing mode to: one\n'
        else
            printf '.xscreensaver file in "%s" not found or not writable.\nNothing was done.\n\n' "${HOME}"
            exit 1
        fi
    ;;
    '--disable')
        if [ -w "${HOME}/.xscreensaver" ]; then
            sed -i -e '/^mode/ s/\b[A-Za-z0-9_]\+$/off/' "${HOME}/.xscreensaver" 
            printf 'xscreensaver disabled by changing mode to: off\n'
        else
            printf '.xscreensaver file in "%s" not found or not writable.\nNothing was done.\n\n' "${HOME}"
            exit 1
        fi
    ;;
    '--set-timeout')
        shift
        xsc_minute=0
        xsc_hour=0
        if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] 2>/dev/null; then
            xsc_minute="${1}"
        else
            printf 'ERROR: No minute value, or non-numeric integer value provided.\n'
            exit 1
        fi

        if [ -n "${2}" ]; then
            if [ "${2}" -eq "${2}" ] 2>/dev/null; then
                xsc_hour="${2}"
            else
                printf 'ERROR: Non-numeric integer value provided for hour.\n'
                exit 1
            fi
        fi
        if [ "${xsc_minute}" -le 9 ]; then
            xsc_minute=0"${xsc_minute}"
        fi
        #if [ "${xsc_hour}" -le 9 ]; then
        #    xsc_hour=0"${xsc_hour}"
        #fi
        if [ -w "${HOME}/.xscreensaver" ]; then
            sed -i -e '/^timeout:/ s/\b[0-9:]\+$/'"${xsc_hour}"':'"${xsc_minute}"':00/'
        else
            printf '.xscreensaver file in "%s" not found or not writable.\nNothing was done.\n\n' "${HOME}"
        fi
    ;;
    '--status')
        printf 'xscreensaver is currently: %s\n' "${xsc_state}"
        exit 0
    ;;
    *)
        printf '%s\n\n' 'Invalid Action Specified.  Please refer to help below'
        xsc_showhelp
    ;;
esac

                                            
