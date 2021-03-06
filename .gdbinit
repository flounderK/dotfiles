#source /usr/share/pwndbg/gdbinit.py
#source /usr/share/peda/peda.py
source ~/.local/share/pwndbg/gdbinit.py
source ~/.local/share/gef/gef.py
unset env LINES
unset env COLUMNS
set disassembly-flavor intel
alias ir=info register
set height 0
set width 0
set print object on

