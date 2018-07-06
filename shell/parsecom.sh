#!/bin/sh


sArgs(){
    printf '%s' "$(printf '%s' "${1}" | sed -e 's/^-//' -e 's/\(.\)/-\1 /g' -e 's/\s$//')"
}

formatArgs(){
    fA_FLAG_print=1
    argString=''

    if [ "${1}" = "noprint" ]; then
        fA_FLAG_print=0
        shift
    fi

    while [ -n "${1}" ]; do
        case ${1} in
            --*)
                argString="${argString}${1} "
                shift
                ;;
            -?)
                argString="${argString}${1} "
                shift
                ;;
            -*)
                argString="${argString}$(sArgs "${1}") "
                shift
                ;;

            *)
                argString="${argString}\"${1}\" "
                shift
                ;;
        esac
    done
    fAArgs="${argString%% }"
    if [ "${fA_FLAG_print}" -eq 1 ]; then
        printf '%s\n' "${fAArgs}"
    fi
}
