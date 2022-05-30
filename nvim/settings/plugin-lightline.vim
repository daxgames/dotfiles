let g:lightline = {
   \ 'mode_map': { 'c': 'NORMAL' },
   \ 'active': {
   \   'left': [ [ 'mode', 'paste' ], [ 'cocstatus', 'fugitive', 'filename' ] ]
   \ },
   \ 'component_function': {
   \   'modified': 'MyModified',
   \   'readonly': 'MyReadonly',
   \   'fugitive': 'MyFugitive',
   \   'filename': 'MyFilename',
   \   'fileformat': 'MyFileformat',
   \   'filetype': 'MyFiletype',
   \   'fileencoding': 'MyFileencoding',
   \   'mode': 'MyMode',
   \   'cocstatus': 'coc#status',
   \ },
   \ 'separator': { 'left': '', 'right': '' },
   \ 'subseparator': { 'left': '', 'right': '' }
\ }

autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  if &ft !~? 'vimfiler\|gundo' && exists("*FugitiveHead")
    let _ = FugitiveHead()
    return strlen(_) ? ' '._ : ''
  endif
  return ''
endfunction

function! MyFileformat()
  return '' " Experimenting leaving without this section for now (it almost never changes...)
  return winwidth(0) > 70 ? &fileformat : ''
  " return winwidth(0) > 70 ? &fileformat . ' ' . WebDevIconsGetFileFormatSymbol() : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! MyFileencoding()
  return '' " Experimenting leaving without this section for now (it almost never changes...)
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth('.') > 60 ? lightline#mode() : ''
endfunction
