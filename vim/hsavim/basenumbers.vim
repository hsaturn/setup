fun! ShowBase()
  let l:word=expand("<cword>")
  if l:word =~ '[0-9]\+'
    let l:n = str2nr(l:word)
    let l:hexa=printf("%x", l:n)
    let l:echo=""
    let l:sep="-"
    while len(l:hexa)
      let l:len=len(l:hexa)
      if len(l:echo)
        let l:echo=l:sep . l:echo
      endif
      if l:len>4
        let l:echo=l:hexa[l:len-4:] . l:echo
        let l:hexa=l:hexa[:l:len-5]
      else
        let l:echo=l:hexa.l:echo
        let l:hexa=""
      endif
    endwhile
    if len(l:echo)
      let l:echo="0x".l:echo
    endif
    let l:convert=printf("Number: %s, %s", l:n, l:echo)
    echo l:convert
  endif
endfun

augroup show_base
  autocmd!
  autocmd CursorMoved * :call ShowBase()
augroup end
