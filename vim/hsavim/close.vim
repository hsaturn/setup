function! CloseIfNotLast()
  if winbufnr(2) != -1 || tabpagenr('$')>1
    quit
  else
    echo "I won't close the last window"
  endif
  call DeleteHiddenBuffers()
endfunction

function! DeleteHiddenBuffers()
  let tpbl=[]
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    silent execute 'bwipeout' buf
  endfor
endfunction

nnoremap @ :call CloseIfNotLast()<CR>
nnoremap <C-w><C-w> :call CloseIfNotLast()<CR>
