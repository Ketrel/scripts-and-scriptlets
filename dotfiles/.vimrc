"filetype plugin on
"
" runtime colors/default.vim
"
syntax on
set backspace=eol,indent,start
set expandtab
set tabstop=4
set shiftwidth=4
set fo-=t
set fo-=c
set number
set nowrap

" colorscheme synthwave-mod
" nmap <silent> <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
