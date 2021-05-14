" Mouse functions
" ===============

if has("mouse_sgr")
  set ttymouse=sgr
else
  set ttymouse=xterm2
endif

function! ToggleMouse()
  if &mouse == "a"
    set mouse=
  else
    set mouse=a
  endif
endfunction

nnoremap <F2> :call ToggleMouse()<CR>
