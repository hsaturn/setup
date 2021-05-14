" pipe = vertical split, underscore=horizontal split
nnoremap - :vsplit<CR>
nnoremap _ :split<CR>

" Move between windows with CTRL + cursor
map <C-LEFT> :wincmd h<CR>
map <C-RIGHT> :wincmd l<CR>
map <C-UP> :wincmd k<CR>
map <C-DOWN> :wincmd j<CR>

augroup CursorLineOnyInActiveWindow
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

set cursorline
hi cursorLine ctermbg=17
hi CursorLine ctermbg=black cterm=bold
hi Search ctermfg=black ctermbg=yellow
hi IncSearch ctermfg=grey ctermbg=60
