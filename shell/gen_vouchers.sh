#!/bin/sh

# Path to soffice binary
sobin='/cygdrive/c/Program Files/LibreOffice/program/soffice.exe'

# Other paths
startDir="${PWD}"
workingDir="${PWD}/working"
odtBase="${PWD}/partials/base"
contentBase="${PWD}/partials"
outputDir="${PWD}/output"
case "$(uname -s)" in
    CYGWIN*) outputDir="$(cygpath -w "${outputDir}")";;
esac

page=1
rm -r "${workingDir:?}/"* 2>/dev/null
printf '' > "${workingDir:?}/guts"
while read -r line; do
    sed -e "s/%VOUCHER%/${line}/g" -e "s/%PAGE%/${page}/g" "${contentBase}/content_guts.xml" >> "${workingDir:?}/guts"
    page=$((page + 1))
    
done < vouchers.txt
guts="$(cat "${workingDir:?}/guts")"
awk -v guts="${guts}" '{sub(/%DATA%/, guts);print}' "${contentBase}/content_frame.xml" > "${workingDir:?}/content.xml"
rm "${workingDir:?}/guts"
cp -r "${odtBase}/"* "${workingDir:?}/"
cd "${workingDir}" || exit 1
thetime="$(date +'%Y-%m-%d-%H%M%S')"
odt="./voucher_${thetime}.odt"
zip -r "${odt}" ./* -x '*.odt'
"${sobin}" --headless --convert-to pdf --outdir "${outputDir}" "${odt}"
cd "${startDir}" || exit 1
rm -r "${workingDir:?}/"* 2>/dev/null
