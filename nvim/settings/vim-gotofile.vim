" Automatically jump to a file at the correct line number
" i.e. if your cursor is over /some/path.rb:50 then using 'gf' on it will take
" you to that line

" use ,gf to go to file in a vertical split
nnoremap <silent> <leader>of   :vertical botright wincmd F<CR>

" Externally open a file
nnoremap gO :!open <cfile><CR>
