"
" runtime colors/default.vim
"

" Default Color Scheme        
let g:color_Default = 'tokyo-metro'
let g:color_Readonly = 'nighted'

set nocompatible
imap <ESC>oA <ESC>ki
imap <ESC>oB <ESC>ji
imap <ESC>oC <ESC>li
imap <ESC>oD <ESC>hi

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
let indentexpr=''

set fo-=t
set fo-=c
set numberwidth=4
set number
set nowrap

nmap <silent> <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Dev Options
set autoindent
set softtabstop=4

" Color Schemes

function ReadOnlyColor()
    if &readonly
        execute 'colorscheme '.g:color_Readonly
    else
        execute 'colorscheme '.g:color_Default
    endif
endfunction

" call ReadOnlyColor()
" augroup readonly
"     autocmd!
"     " autocmd BufReadPost * call ReadOnlyColor()
"     autocmd BufReadPost,BufEnter,BufLeave * call ReadOnlyColor()
" augroup END
