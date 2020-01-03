./toybox-i686 find "${PWD}" -maxdepth 1 -name '*fake*' -exec ./toybox-i686 stat -c './toybox-i686 touch -c -m -d "%y" "%n"' {} \;
