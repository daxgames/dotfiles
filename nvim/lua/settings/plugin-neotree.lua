require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  }
}

vim.keymap.set('n', 'nt', '<Cmd>Neotree toggle<CR>')
vim.keymap.set('n', '<C-\\>', '<Cmd>Neotree reveal<CR>')

