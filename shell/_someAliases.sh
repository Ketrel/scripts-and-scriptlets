export TERM=xterm-256color
alias ls='ls --color=auto -X --group-directories-first'
# alias memfree='free | grep Mem | awk '"'"'{printf("Memory Stats\n----------\nUsed: %.1f%% (%.0f)\nFree: %.1f%% (%.0f)\nTotal: 100%% (%.0f)\n\n",($3/$2 * 100.0),$3,($4/$2 * 100.0),$4,$2)}'"'"';top -abn 1 | tail -n +7 | head -n 11 | awk '"'"'{printf("%-7s %-9s %-9s %-6s %-5s %-5s %-9s\n", $1, $2, $5, $6, $9, %10, $12)}'"'"''
alias memfree='free | grep Mem | awk '"'"'{printf("Memory Stats\n----------\nUsed: %.1f%% (%.0f)\nFree: %.1f%% (%.0f)\nTotal: 100%% (%.0f)\n\n",($3/$2 * 100.0),$3,($4/$2 * 100.0),$4,$2)}'"'"';top -bn 1 -s 9 | tail -n +7 | head -n 11 | awk '"'"'{printf("%-7s %-9s %-9s %-6s %-5s %-5s %-9s\n", $1, $2, $5, $6, $9, %10, $12)}'"'"''
clear; echo 'Setup Done'

