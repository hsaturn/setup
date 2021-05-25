let s:show_func_name=1
let s:shown_func=0

function! ToggleFuncName()
  let s:show_func_name = 1 - s:show_func_name
  if s:show_func_name
      echo "Show function name enabled"
    else
      echo "Show function name disabled"
    endif
  endif
endfunction
nnoremap <F9> :call ToggleFuncName()

function! ShowFuncName()
  if s:show_func_name
    let l:maxs=&columns-50
    if l:maxs>10
      let l:line=getline(line('.'))
      if l:line[:0]==' ' || l:line[:0]=='\t'
        let s:shown_func=1
        echohl ModeMsg
        set shortmess=at
        let l:msg=getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bWn'))[:l:maxs]
        echo l:msg
        echohl None
      else
        if s:shown_func==1
          let s:shown_func=0
          echo expand('%:p')
        else
          echo expand('%s:p')
        endif
      endif
    endif
  endif
endfunction

" Workaround for CursorMoved not being able to
" fire when cursor at bottom of window stays there
" only the content of the windows scrolls
map <silent> f :call ShowFuncName()<CR>
nmap <Down> jf
nmap <Up> kf
nmap <PageDown> <C-f>f
nmap n nf
augroup show_funcname
  autocmd!
  autocmd CursorMoved * :call ShowFuncName()
augroup end
