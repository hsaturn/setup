" alt *   same as *, but opens a search results quicklist
" gw      same as alt *
" F3      goto next
" S-F3    goto prev
" F4      goto previous search list
" S-F4    goto next search list

" mode='c' F3 F4 uses the error list (copen)
" mode='l' F3 uses vimgrep list (lopen, lnext...)
let g:f3_mode='c'

nnoremap <F3>   :execute(g:f3_mode."next")<CR>
nnoremap <S-F3> :execute(g:f3_mode."previous")<CR>

function! F3SearchWord(word)
  let g:f3_mode='l'
  execute 'lvim /'.a:word.'/ %'
  execute 'lopen'
  execute 'wincmd p'
  let @/ = a:word
endfunction

" ALT *
" nnoremap * :lvim /<c-r>=expand("<cword>")<cr>/ %<cr>:lopen<cr>:wincmd p<cr>
nnoremap <silent> * :call F3SearchWord(expand("<cword>"))<CR>

