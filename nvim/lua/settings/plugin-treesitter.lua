-- nvim-treesitter(master) config - legacy
-- local config = require("nvim-treesitter.configs")
-- config.setup({
--   -- A list of parser names, or "all" (the five listed parsers should always be installed)
--   ensure_installed = { "lua", "vim", "vimdoc", "yaml", "json", "bash", "javascript", "ruby", "diff" },
--   auto_install = true,
--   indent = {
--     enable = true,
--   },
--   highlight = {
--     enable = true,
--   },
-- })

-- nvim-treesitter(main) install
require('nvim-treesitter').setup({
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site',
  auto_install = true,
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
})

require("nvim-treesitter").install({
  "lua", "vim", "vimdoc", "yaml", "json", "bash", "javascript", "ruby", "diff"
})

