require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup({
  automatic_installation = true,
  ensure_installed = {
    "bashls",
    "gradle_ls",
    "groovyls",
    "jinja_lsp",
    "lua_ls",
    "rubocop",
    "ruby_lsp",
    "tsserver",
    "yamlls",
  }
})

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.bashls.setup {}
lspconfig.gradle_ls.setup {}
lspconfig.groovyls.setup {}
lspconfig.jinja_lsp.setup {}
lspconfig.lua_ls.setup {}
lspconfig.ruby_lsp.setup {}
lspconfig.tsserver.setup {}
lspconfig.yamlls.setup {}

vim.keymap.set('n', 'gf', vim.lsp.buf.format, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sh',
  callback = function()
    vim.lsp.start({
      name = 'bash-language-server',
      cmd = { 'bash-language-server', 'start' },
    })
  end,
})
