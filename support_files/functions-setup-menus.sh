#!/bin/sh

mainMenu(){
    menuSelection="0"
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(${tuiBin} \
            --backtitle "Setup${titleAdditions}" \
            --menu \
                "Automated Setup Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
                "1" "Choose scripts to copy to scripts dir" \
                "2" "Choose dotfiles to copy to dotfiles dir" \
                "-" "" \
                "B" "Bulk Copy Actions" \
                "-" "" \
                "C" "Configuration Options" \
                "?" "Show Current Config" \
                "-" "" \
                "Q" "Quit" \
            2>&1 1>&3); then return 1; fi
    done
    mainMenuReturn="${menuSelection}"
    return 0
}

bulkMenu(){
    menuSelection='0'
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(${tuiBin} \
            --backtitle "Setup${titleAdditions}" \
            --cancel-button "Main Menu" \
            --menu \
                "Bulk Copy Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
            "1" "Copy ALL scripts to scripts dir" \
            "2" "Copy ALL dotfiles to dotfiles dir" \
            "3" "Copy ALL dotfiles (sans .profile) to dotfiles dir" \
            "-" "" \
            "<" "Return to Main Menu" \
            2>&1 1>&3); then return 1; fi
        case "${menuSelection}" in
            '1')
                if ! yesnoBox "Ready to copy ALL included scripts\\n  to the scripts dir?"; then
                    menuSelection='0'
                fi
                ;;
            '2')
                if ! yesnoBox "Ready to copy ALL included dotfiles\\n  to the dotfiles dir?"; then
                    menuSelection='0'
                fi
                ;;
            '3')
                if ! yesnoBox "Ready to copy ALL included dotfiles\\n(excluding .profile)\\n  to the dotfiles dir?"; then
                    menuSelection='0'
                fi
                ;;
        esac
    done
    bulkMenuReturn="${menuSelection}"
    return 0
}

optionsMenu(){
    menuSelection='0'
    while [ "${menuSelection}" = "0" ] || [ "${menuSelection}" = "-" ]; do
        if ! menuSelection=$(${tuiBin} \
            --backtitle "Setup${titleAdditions}" \
            --cancel-button "Main Menu" \
            --menu \
                "Configuration Options" \
                ${mainHeight} \
                ${mainWidth} \
                ${menuHeight} \
            "1" "Set Scripts Destination Directory" \
            "2" "Set Dotfiles Destination Directory" \
            "-" "" \
            "?" "Show Current Config" \
            "C" "Create Missing Directories (Not Implimented)" \
            "B" "Add lines to read '.customize_prompt' to .bashrc" \
            "P" "Add lines to include scripts dir in path to .profile" \
            "-" "" \
            "D" "Preview A Dotfile" \
            "S" "Preview A Script" \
            "-" "" \
            "<" "Return to Main Menu" \
            2>&1 1>&3); then return 1; fi
    done
    optionsMenuReturn="${menuSelection}"
    return 0
}

