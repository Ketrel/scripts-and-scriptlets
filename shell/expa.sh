#!/bin/sh

selfdir="$( dirname "$(readlink -f "${0}")")"
sedscript_i=$(cat <<'EOF'
/\. ".\{1,\}\.sh"/ { 
s/\. //
s/"//g
s#${supportdir}#./support_files#
}
EOF
)

sedscript_o=$(cat <<'EOF'
s#${supportdir}#./support_files#
/^supportdir=/d
EOF
)

if [ -f "${1}" ]; then
    while IFS= read -r line; do
        if printf '%s\n' "${line}" | grep -q '\. .*'; then
            file=$(printf '%s\n' "${line}" | sed -e "${sedscript_i}")
            cat "${file}"
            continue
        fi
        printf '%s\n' "${line}" | sed -e "${sedscript_o}" 
    done < "${1}"    
fi
