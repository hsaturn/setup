let s:context_rows=5
let s:pipe=-1
let s:cursor=""
let s:debug=0

" probably deleted char how to handle this ?
fun! GridTextChanged()
"  call Decho("changed ! ".s:pipe)
  call GridTextChangedI()
endfunction 

" reformat the line so the pipe next to col moves to expected position
" returns the new expected position if it has moved or -1 if it was impossible
fun! GridReformatGrid(row, col, expected)
  echohl ModeMsg
  set shortmess=at
  " try to remove space at end of cell
"  call Decho("GridReformat(".a:row.", ".a:col.", ".a:expected.") ".s:debug)
  let s:debug=s:debug+1
  let l:text = getline(a:row)
  let l:next_pipe=stridx(l:text, '|', a:col)
"  call Decho("np=".l:next_pipe) 
  if l:next_pipe == -1
    return
  endif
  while l:next_pipe != a:expected
    " Avoid infinite loops
    let l:old_text = l:text
    if l:next_pipe > a:expected
      if l:text[l:next_pipe-1]==' ' && l:text[l:next_pipe-2]==' '
"        call Decho("remove char next=".l:next_pipe." expected=".a:expected." debug=".s:debug)
        let l:text = l:text[:l:next_pipe-2].l:text[l:next_pipe:]
        call setline(a:row, l:text)
      else
        " current cell has been enlarged
        " enlarge cell by trying to reformat right cell
        call setline(a:row, l:text)
        let l:offset=l:next_pipe - a:expected
        let l:expected = stridx(l:text, '|', l:next_pipe+1) - l:offset
        let l:result = GridReformatGrid(a:row, l:next_pipe+1, l:expected)
"        call Decho("next GridReformatGrid(".a:row.", ".(l:next_pipe+1).", ".l:expected.")")
        " enlarge up if not a border
        if getline(a:row-1)[a:expected] == '|'
"          call Decho("enlarge up row") 
          call GridReformatGrid(a:row-1, l:next_pipe-1, l:next_pipe)
        endif 
      endif
    else
      " Cell has been reduced, re-enlarge it (yet)
      while l:next_pipe > -1
"        call Decho("Enlarg cell ".l:next_pipe." (".getline(a:row-1)[l:next_pipe])
"        call Decho("Enlarg cell ".l:next_pipe." (".getline(a:row-1)[l:next_pipe+1])
        if getline(a:row-1)[l:next_pipe+1] == '|' || getline(a:row-1)[l:next_pipe+1]=='+' 
"          call Decho(l:text) 
          let l:text = l:text[:l:next_pipe-1].' '.l:text[l:next_pipe:]
"          call Decho(l:text) 
        endif 
        let l:next_pipe = stridx(l:text, '|', l:next_pipe+1) 
      endwhile 
      call setline(a:row, l:text) 
      return stridx(l:text, '|', a:col)
    endif
    let l:next_pipe=stridx(l:text, '|', a:col)
    if l:old_text == l:text
"      call Decho("unable to reformat grid (".l:text.") expected(".a:expected.") next(".l:next_pipe)
      return -1
    endif
  endwhile
"  call Decho("return ".l:next_pipe) 
  return l:next_pipe
endfunction

fun! GridCursorMoved()
  let l:cursor=line('.').'-'.col('.')
  if (l:cursor == s:cursor)
    return
  endif
"  call Decho("CursorMoved ".l:cursor." old=".s:cursor)
  if InGrid()
    let s:pipe=stridx(getline('.'), '|', col('.'))
"    call Decho("in grid ".s:pipe)
  else
    let s:pipe=-1
"    call Decho("out of grid")
  endif
 let s:cursor=l:cursor 
endfunction

fun! GridTextChangedI()
  if s:pipe!=-1
    call DechoSep("TextChangedI(".s:pipe.")")
    let s:pipe = GridReformatGrid(line('.'), col('.')-1, s:pipe)
"    call Decho("TextChangedI out=".s:pipe) 
  else
"    call Decho("no pipe")
  endif
endfunction

fun! GridStop()
  let s:pipe=-1
endfunction

fun! GridInsertLeave()
"  call Decho("Insert leave")
endfunction 

fun! GridInsertCharPre()
  return
"  call Decho("pre ".v:char)
  return
  if InGrid()
    let s:pipe=col('.')
"    call Decho("pre insert(".v:char.")")
  else
    if s:pipe!=""
      let s:pipe=v:char
    else
"      call Decho("not in grid")
    endif
  endif
endfunction

fun! InGrid()
  echohl ModeMsg
  let l:col=col('.')-1 
  set shortmess=at
  let l:first_pipe = strridx(getline('.'), '|', l:col)
  if l:first_pipe == -1
    return 0
  endif
  let l:last_pipe = stridx(getline('.'), '|', l:col+1)
  if l:last_pipe == -1
    return 0
  endif
  let l:line = getline('.')
  let l:row = line('.')
"  " call Decho("current first_pipe=".l:first_pipe." row ".l:row." col ".l:col)
  let l:in=0
  for row in range(l:row-1, l:row-s:context_rows, -1)
      if getline(row)[l:col]=='-' && getline(row)[l:first_pipe]=='+' && getline(row)[l:last_pipe]=='+'
        let l:in=1
        break
      endif
      if getline(row)[l:first_pipe]!='|'
        return 0
      endif
      if getline(row)[l:last_pipe]!='|'
        return 0
      endif
  endfor
  if l:in==0
    return 0
  endif
  for row in range(l:row+1, l:row+s:context_rows)
      if getline(row)[l:col]=='-' && getline(row)[l:first_pipe]=='+' && getline(row)[l:last_pipe]=='+'
        let l:in=2
        break
      endif
  endfor
  if l:in == 2
    return 1
  endif
  return 0
endfunction

fun! GridTest()
  call GridEcho("TEST")
endfunction

fun! IsGrid(char)
  if a:char=='+' || a:char=='-' || a:char=='|'
    return 1
  else
    return 0
  endif
endfun

augroup grid
  autocmd!
  autocmd CursorMoved * :call GridCursorMoved()
  autocmd TextChanged * :call GridTextChanged()
  autocmd InsertCharPre * :call GridInsertCharPre()
  autocmd InsertLeave * :call GridInsertLeave()
  autocmd TextChangedI * :call GridTextChangedI()
  " See TextYankPost
augroup end

nmap <C-S> :w<CR>:so %<CR>
imap <C-S> <Esc>:w<CR>:so %<CR>a
nmap t :call InGrid()<CR>
nmap T :call FakeInsert()<CR>
