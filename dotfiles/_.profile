# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Add user bin directory to PATH if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Add user scripts directory to PATH if it exists
if [ -d "$HOME/scripts" ] ; then
    PATH="$HOME/scripts:$PATH"
fi

# Add user Scripts directory to PATH if it exists
if [ -d "$HOME/Scripts" ] ; then
    PATH="$HOME/Scripts:$PATH"
fi

# Putty Fix
export NCURSES_NO_UTF8_ACS=1
