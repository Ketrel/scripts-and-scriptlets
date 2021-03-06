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
" let indentexpr=''
set indentexpr=

set fo-=t
set fo-=c
set numberwidth=4
set number
set nowrap

" To make spltting how I like
set splitright
set splitbelow

" nmap <silent> <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Dev Options
set autoindent
set softtabstop=4

" Add a Ctrl + Alt + L mapping to toggle line highliting
"nmap <silent> <M-C-L> :set cursorline!<CR>
nmap <silent> <C-L> :set cursorline!<CR>

set laststatus=1

" Color Schemes
function ReadOnlyColor()
"    if &readonly && &t_Co >= 256
    if ($TERM == 'linux' || $TERM == 'xterm')
        " Do nothing, since it's not 256 colors, regardless of what the devs claim
    else
        if (&readonly) 
            execute 'colorscheme '.g:color_Readonly
        else
            execute 'colorscheme '.g:color_Default
        endif
    endif
endfunction

call ReadOnlyColor()
augroup readonly
    autocmd!
    " autocmd BufReadPost * call ReadOnlyColor()
    autocmd BufReadPost,BufEnter,BufLeave * call ReadOnlyColor()
augroup END
