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
    "lua_ls",
    "tsserver",
    "gradle_ls",
    "groovyls",
    "yamlls",
    "jinja_lsp",
  }
})

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup {}
lspconfig.tsserver.setup {}
lspconfig.groovyls.setup {}
lspconfig.yamlls.setup {}
lspconfig.jinja_lsp.setup {}

vim.keymap.set('n', 'gf', vim.lsp.buf.format, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
