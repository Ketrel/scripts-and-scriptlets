#!/bin/sh

# Path to soffice binary
sobin='/cygdrive/c/Program Files/LibreOffice/program/soffice.exe'

# Other paths
startDir="${PWD}"
workingDir="${PWD}/working"
odtBase="${PWD}/partials/base"
contentBase="${PWD}/partials"
outputDir="${PWD}/output"

# Reusable Variables
thetime="$(date +'%Y-%m-%d-%H%M%S')"
outOdt="voucher_${thetime}.odt"
outPdf="voucher_${thetime}.pdf"
slash='\'

case "$(uname -s)" in
    CYGWIN*)
        outputDir="$(cygpath -w "${outputDir}")"
        slash='/'
        ;;
esac
page=1
rm -r "${workingDir:?}/"* 2>/dev/null
printf '' > "${workingDir:?}/guts"

echo "Reading in 'vouchers.txt'"
echo "----------"
    while read -r line; do
        echo "Generating Sheet For Voucher: ${line}"
        sed -e "s/%VOUCHER%/${line}/g" -e "s/%PAGE%/${page}/g" "${contentBase}/content_guts.xml" >> "${workingDir:?}/guts"
        page=$((page + 1))
    done < vouchers.txt
echo "----------"
echo

echo "Assembling Document"
echo "----------"
echo "No output expected in this section"
    guts="$(cat "${workingDir:?}/guts")"
    awk -v guts="${guts}" '{sub(/%DATA%/, guts);print}' "${contentBase}/content_frame.xml" > "${workingDir:?}/content.xml"
    rm "${workingDir:?}/guts"
    cp -r "${odtBase}/"* "${workingDir:?}/"
    cd "${workingDir}" || exit 1
    zip -r "./${outOdt}" ./* -x '*.odt' > /dev/null
echo "----------"
echo

echo "Creating PDF From Document"
echo "----------"
echo "No output expected in this section"
    "${sobin}" --headless --convert-to pdf --outdir "${outputDir}" "./${outOdt}" >/dev/null 2>&1
    cd "${startDir}" || exit 1
    rm -r "${workingDir:?}/"* 2>/dev/null
echo "----------"
echo

echo "Done: PDF Should Be In '${outputDir}${slash}${outPdf}'"
