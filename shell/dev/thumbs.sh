#!/bin/sh

if [ ! -f "${1}" ]; then
    printf "Error: File Not Specified or Does Not Exist\n"
    exit 1
fi

frameCount=$(\
    ffmpeg \
    -hide_banner \
    -i "${1}" \
    -map 0:v:0 \
    -c copy \
    -f null \
    - 2>&1 \
        | grep \
            -oe 'frame=[0-9]\+' \
        | cut \
            -d '=' \
            -f 2)

ffmpeg -i "${1}" -vf fps=1/60 "./thumb_test/img%03d.jpg"
            
#printf -- "---%d---\n" ${frameCount}

