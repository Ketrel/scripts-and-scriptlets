#!/bin/sh

if [ ! -f "${1}" ]; then
    printf "Error: File Not Specified or Does Not Exist\n"
    exit 1
else
    vidName="${1%%.*}"
fi

#frameCount=$(\
#    ffmpeg \
#        -hide_banner \
#        -i "${1}" \
#        -map 0:v:0 \
#        -c copy \
#        -f null \
#        - 2>&1 \
#            | grep \
#                -oe 'frame=[0-9]\+' \
#            | cut \
#                -d '=' \
#                -f 2)

if [ ! -d "./${vidName}" ]; then
    mkdir "${vidName}"
fi
vidLength=$(\
    ffprobe \
        -i "${1}" \
        -v error \
        -show_format\
            | grep 'duration' \
            | cut -d '=' -f 2 \
            | xargs printf '%.0f\n')
ffmpeg -i "${1}" -vf fps=15/${vidLength}  "./${vidName}/img%03d.jpg"
cd "${vidName}"
montage img*.jpg -tile '4x' -geometry '360x>' "${vidName}_thumbs.jpg"
mv "${vidName}_thumbs.jpg" ..
rm *.jpg
cd ..
rmdir "${vidName}"
