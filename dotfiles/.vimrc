"
" runtime colors/default.vim
"

set nocompatible
" imap <ESC>oA <ESC>ki
" imap <ESC>OB <ESC>ji
" imap <ESC>OC <ESC>li
" imap <ESC>OD <ESC>hi

filetype indent off
filetype plugin off
syntax on

set backspace=eol,indent,start

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0
set nosmarttab

set noautoindent
set nocindent
set indentexpr=''

set fo-=t
set fo-=c
set numberwidth=4
set number
set nowrap

" colorscheme synthwave-mod
" nmap <silent> <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
