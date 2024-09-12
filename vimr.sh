#!/bin/bash

tmpfile=$(mktemp -p /tmp vimr.XXXXXX)
cat << EOF > "$tmpfile"
let g:vimr_shell = ""
let g:vimr_shell_linux = "bash"
let g:vimr_shell_windows = "pwsh"
let g:vimr_shell_macos = "zsh"
let g:vimr_data_src = ""

if has("win32")
    let g:vimr_shell = g:vimr_shell_windows
endif
if has("linux")
    let g:vimr_shell = g:vimr_shell_linux
endif
if has("mac")
    let g:vimr_shell = g:vimr_shell_macos
endif

function! CheckVimrFile() abort
    let current_directory = expand('%:p:h')
    let vimr_file = current_directory . '/vimr'
    if !empty(glob(vimr_file))
        return v:true
    else
        return v:false
    endif
endfunction

function! VimrList()
    let current_directory = expand('%:p:h')
    let vimr_file = current_directory . '/vimr'
    if CheckVimrFile()
        let result = readfile(vimr_file)
        let lines = result
        let g:vimr_data_src = "vimr"
    else
        if has("win32")
            let result = system('dir /B ' . current_directory)
        endif
        if has("linux")
            let result = system('ls -1 ' . current_directory)
        endif
        if has("mac")
            let result = system('ls -1 ' . current_directory)
        endif

        let lines = split(result, '\n')
        "let lines = map(lines, '"./" . v:val')
        let g:vimr_data_src = "files"
    endif

    enew 
    call setline(1, lines)
    :%center
endfunction

function! Vimr(commands)
    for cmd in a:commands
        if g:vimr_data_src == "files"
            let cmd = "./" . cmd
        endif
        call term_sendkeys(g:buf, cmd . "\<CR>")
    endfor
endfunction

function! Vimrr() 
    let current_line = getline('.')
    let stripped_line = substitute(current_line, '^\s*', '', '')
    let mylist = []
    call add(mylist, stripped_line)
    call Vimr(mylist)
endfunction

call VimrList()
:highlight CursorLine guibg=darkgreen guifg=black ctermbg=green ctermfg=black
:setlocal cursorline
:setlocal nomodifiable
nnoremap <buffer> <Enter> :call Vimrr()<Enter>
nnoremap <buffer> Q :qa!<Enter>
set splitbelow
let g:buf =  term_start(g:vimr_shell, {'term_name': 'vimr'})
call term_sendkeys(g:buf, "cd " . expand('%:p:h') . "\<CR>")
execute "normal! \<C-w>p"
EOF

vim --clean  -c "source $tmpfile"