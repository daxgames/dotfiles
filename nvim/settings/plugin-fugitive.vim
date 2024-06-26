" The tree buffer makes it easy to drill down through the directories of your
" git repository, but it’s not obvious how you could go up a level to the
" parent directory. Here’s a mapping of .. to the above command, but
" only for buffers containing a git blob or tree
autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

" Every time you open a git object using fugitive it creates a new buffer.
" This means that your buffer listing can quickly become swamped with
" fugitive buffers. This prevents this from becomming an issue:

autocmd BufReadPost fugitive://* set bufhidden=delete

" Mappings
" ============================
nnoremap <leader>gd :Git diff<cr>
nnoremap <leader>gs :Git status<cr>
nnoremap <leader>gw :Git write<cr>
nnoremap <leader>ga :Git add %<cr>
nnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gco :Git checkout<cr>
nnoremap <leader>gci :Git commit<cr>
nnoremap <leader>gm :Git move
nnoremap <leader>gr :Git remove<cr>

" For fugitive.git, dp means :diffput. Define dg to mean :diffget
nnoremap <silent> <leader>dg :diffget<CR>
nnoremap <silent> <leader>dp :diffput<CR>
