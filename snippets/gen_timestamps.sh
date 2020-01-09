find ${PWD} -type f -exec stat -c '$TOUCHCMD --no-create -d "%y" "%n"' {} \;
