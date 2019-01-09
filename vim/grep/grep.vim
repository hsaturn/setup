function GrepAll(word)
	if a:word==""
		echo "Cannot grep empty word"
	else
		let g:LastGrepAll=a:word
		:silent execute ':grep "' .a:word.'" -rw --include \*.h --include \*.hxx --include \*.hpp --include \*.c --include \*.cpp --include \*.xml --exclude=tags *'
		copen
		:silent! cr
		:silent! execute ':match Search /' . a:word . '/'
	endif
endfunction

function CloseUselessBuffers()
	let buffers = range(1,bufnr('$'))
	let ns_bufs = filter(buffer, 'bufname(v:val) == ""')
	call DeleteBuffers(ns_bufs)
endfunction

function DeleteBuffers(ns_bufs)
	for buffer in a:ns_bufs
		if buflisted(buffer)
			try
				execute 'confirm bdelete ' . buffer
				catch
			endtry
		endif
	endfor
endfunction

nnoremap gw :call GrepAll('<C-r><C-w>')<CR><CR>
nnoremap ga :call GrepAll('')<left><left>
nnoremap <F3> :cn<CR>
nnoremap <S-F3> :cp<CR>
nnoremap <F4> :call CloseUselessBuffers()<CR>


