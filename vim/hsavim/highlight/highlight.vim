" Why not miami
" Miami Is Another Marker Implementation
if exists('g:loaded_highlight')
  finish
else
  let g:loaded_highlight = 1

  " Global configuration / keymap
  noremap h     :call HighLightHandler(expand("<cword>"), 0)<cr>
  noremap H     :call HighLightHandler(expand("<cword>"), 1)<cr>
  noremap <C-h> :call HighLightToggleHandler()<cr>
  " 'all' highlight all windows
  " 'win' highlight only current window
  let g:highlight_scope='all'

  " Persistency
  " Theme is a csv like file, 1st row is the name of highlight item
  " eg: ctermbg,ctermfg,...
  "     white,  black,...
  let s:file = expand('<sfile>:p:r').'.theme'
  let s:sg_file=expand('<sfile>:p:r').'.groups'

  " Script vars
  let s:colors={}
  let s:color=0
  let s:toggle=1

endif

function! HighLightWinit()
  if !exists("w:highlights")
    let w:highlights={}
  endif
  if !exists("w:old_highlights")
    let w:old_highlights={}
  endif
endfunction

function! HighLightCreateGroups()
  if !exists("w:create_groups")
    let w:create_groups=1
    let s:groups=[]
    if filereadable(s:file)
      let counter=1
      for line in readfile(s:file)
        let fields=split(line, ',', 1)
        if counter==1
          let cols=fields
        else
          let name="h_".counter
          let cmd="highlight ".name." term=standout "
          for i in range(len(fields))
            let field=fields[i]
            if len(field)
              let cmd=cmd.cols[i].'='.field.' '
            endif
          endfor
          execute cmd
          let s:groups = s:groups+[name]
        endif
        let counter=counter+1
      endfor
    else
      for i in range(6)
        let name="h_".i
        execute "highlight ".name." term=standout ctermfg=0 ctermbg=".(i+10)
        let s:groups = s:groups+[name]
      endfor
    endif
  endif
endfunction

function! HighLightTab(word, recolor)
  call HighLightWinit()
  let recolor=a:recolor
  if recolor==0 && has_key(w:highlights, a:word)
    let recolor=3
  endif
  call HighGetGroup(a:word, a:recolor)
  norm gg
  let curtab = tabpagenr()
  let cmd="tabdo call HighLightHandler('".a:word."', ".recolor.")"
  execute cmd
  execute "tabn ".curtab
endfunction

function! HighLightHandler(word, recolor)
  call HighLightWinit()
  let recolor=a:recolor
  if recolor==0 && has_key(w:highlights, a:word)
    let recolor=3
  endif
  call HighGetGroup(a:word, a:recolor==1)
  let currwin=winnr()
  if g:highlight_scope=='all'
    let cmd="windo call HighLight('".a:word."', ".recolor.")"
  else
    let cmd="windo call HighLight('".a:word."', 4)"

    call HighLight(a:word, recolor)
  endif
  execute cmd
  execute currwin . 'wincmd w'
endfunction

function! HighLightToggleHandler()
  if g:highlight_scope=='all'
    let toggle=s:toggle
    let msg=toggle
    let currwin=winnr()
    execute "windo call HighLightToggle(".s:toggle.")"
    execute currwin.'wincmd w'
    if toggle
      let s:toggle=0
    else
      let s:toggle=1
    endif
  else
    let msg=len(w:highlights)
    call HighLightToggle(len(w:highlights))
  endif
  if msg
    echo "Highlight off"
  else
    echo "Highlight on"
  endif
endfunction

" mode = 0 Toggle word
" mode = 1 Change color of word
" mode = 2 Force highlight
" mode = 3 Force unhighlight
" mode = 4 Update color if already highlighted
function! HighLight(word, mode)
  call HighLightWinit()
  if empty(a:word)
    return
  endif

  let doit=a:mode!=4
  let wordc='\<'.a:word.'\>'
  if has_key(w:highlights, a:word)
    let rmmatch=remove(w:highlights, a:word)
    call HighLightMatchDelete(rmmatch)
    let doit = a:mode==1 || a:mode==2 || a:mode==4
  endif
  if doit && a:mode!=3
    let group=HighGetGroup(a:word, 0)
    call HighLightMatchAdd(group, a:word, wordc)
    " echo "Matching ".doit
  endif
endfunction

function! HighGetGroup(word, recolor)
  call HighLightCreateGroups()
  if has_key(s:colors, a:word) && a:recolor==0
    return s:colors[a:word]
  endif
  if s:color >= len(s:groups)
    let s:color=0
  endif
  let s:colors[a:word] = s:groups[s:color]
  let s:color = s:color+1
  call HighLightSaveGroups()
  return s:colors[a:word]
endfunction

function! HighWinDo(command)
  let currwin=winnr()
  execute 'windo '.a:command
  execute currwin . 'wincmd w'
endfunction

function! HighLightMatchAdd(group, key, word)
  call HighLightWinit()
  let w:highlights[a:key]=matchadd(a:group, a:word)
  let s:toggle=1
endfunction

function! HighLightMatchDelete(n)
  call matchdelete(a:n)
  let s:toggle=0
endfunction

function! HighLightToggle(toggle)
  call HighLightWinit()
  " if len(w:highlights)
  if a:toggle
    let w:old_highlights=w:highlights
    let w:highlights={}
    for key in keys(w:old_highlights)
      call HighLightMatchDelete(w:old_highlights[key])
    endfor
  else
    for key in keys(w:old_highlights)
      let group=HighGetGroup(key, 0)
      call HighLightMatchAdd(group, key, '\<'.key.'\>')
    endfor
  endif
endfunction

function! HighLightShowGroups()
  for key in keys(s:colors)
    echo key."=".s:colors[key]
  endfor
endfunction

function! HighLightSaveGroups()
  let out=[]
  for key in keys(s:colors)
    let out=out+[key."=".s:colors[key]]
  endfor
  call writefile(out, s:sg_file, 'b')
endfunction

function! HighLightSearchNext(flag)
  call HighLightWinit()
  let l:found=999999999
  let l:word=""
  for key in keys(w:highlights)
    let l:srch='\<'.key.'\>'
    let l:pos = search(l:srch, a:flag.'nz')
    if (l:pos < l:found) && l:pos>0
      let l:found=l:pos
      let l:word=l:srch
    endif
  endfor
  if l:word != ''
    call search(l:word)
  endif
endfunction

function! HighLightLoadWordMapping()
  call HighLightCreateGroups()
  let l:groups={}
  for group in s:groups
    let l:groups[group]=1
  endfor
  let s:colors={}
  if filereadable(s:sg_file)
    for line in readfile(s:sg_file)
      let row=split(line,'=',1)
      if len(row)
        if has_key(l:groups, row[1])
          let s:colors[row[0]]=row[1]
        endif
      endif
    endfor
  endif
endfunction

call HighLightLoadWordMapping()

