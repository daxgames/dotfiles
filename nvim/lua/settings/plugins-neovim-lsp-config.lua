local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.rubocop,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.rubyfmt,
  },
})

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
  -- This setting has no relation with the `automatic_installation` setting.
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
  },

  -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
  -- This setting has no relation with the `ensure_installed` setting.
  -- Can either be:
  --   - false: Servers are not automatically installed.
  --   - true: All servers set up via lspconfig are automatically installed.
  --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
  --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
  automatic_installation = true,

  -- See `:h mason-lspconfig.setup_handlers()`
  handlers = nil,
})

-- Setup language servers.
local lspconfig = require("lspconfig")
lspconfig.bashls.setup({})
lspconfig.gradle_ls.setup({})
lspconfig.groovyls.setup({})
lspconfig.jinja_lsp.setup({})
lspconfig.lua_ls.setup({})
lspconfig.ruby_lsp.setup({})
lspconfig.tsserver.setup({})
lspconfig.yamlls.setup({})

vim.keymap.set("n", "gf", vim.lsp.buf.format, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
