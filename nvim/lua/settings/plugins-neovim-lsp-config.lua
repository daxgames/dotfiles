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


local capabilities = vim.lsp.protocol.make_client_capabilities()
local mason_lspconfig = require("mason-lspconfig")
-- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
-- This setting has no relation with the `automatic_installation` setting.
local servers = {
  bashls = {},
  gradle_ls = {},
  groovyls = {},
  jinja_lsp = {},
  lua_ls = {},
  rubocop = {},
  ruby_lsp = {},
  ts_ls = {},
  yamlls = {},
}

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
  -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
  -- This setting has no relation with the `ensure_installed` setting.
  -- Can either be:
  --   - false: Servers are not automatically installed.
  --   - true: All servers set up via lspconfig are automatically installed.
  --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
  --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
  automatic_installation = true,
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- require("mason-lspconfig").setup({
--   -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
--   -- This setting has no relation with the `automatic_installation` setting.
--   ensure_installed = {
--     "bashls",
--     "gradle_ls",
--     "groovyls",
--     "jinja_lsp",
--     "lua_ls",
--     "rubocop",
--     "ruby_lsp",
--     "tsserver",
--     "yamlls",
--   },
--
--   -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
--   -- This setting has no relation with the `ensure_installed` setting.
--   -- Can either be:
--   --   - false: Servers are not automatically installed.
--   --   - true: All servers set up via lspconfig are automatically installed.
--   --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
--   --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
--   automatic_installation = true,
--
--   -- See `:h mason-lspconfig.setup_handlers()`
--   handlers = nil,
-- })
--
-- -- Setup language servers.
-- local lspconfig = require("lspconfig")
-- -- local util = require("lspconfig.util")
--
-- lspconfig.bashls.setup({})
-- lspconfig.gradle_ls.setup({})
-- lspconfig.groovyls.setup({})
-- lspconfig.jinja_lsp.setup({})
-- lspconfig.lua_ls.setup({})
-- lspconfig.ruby_lsp.setup({
-- -- 	default_config = {
-- -- 		cmd = { "bundle", "exec", "ruby-lsp" },
-- -- 		filetypes = { "ruby" },
-- -- 		root_dir = util.root_pattern("Gemfile", ".git"),
-- -- 		init_options = {
-- -- 			enabledFeatures = {
-- -- 	    	"documentHighlights",
-- -- 	    	"documentSymbols",
-- -- 	    	"foldingRanges",
-- -- 	    	"selectionRanges",
-- -- 	    	-- "semanticHighlighting",
-- -- 	    	"formatting",
-- -- 	    	"codeActions",
-- -- 	    },
-- -- 		},
-- -- 		settings = {},
-- -- 	},
-- -- 	commands = {
-- -- 		FormatRuby = {
-- -- 			function()
-- -- 				vim.lsp.buf.format({
-- -- 					name = "ruby_lsp",
-- -- 					async = true,
-- -- 				})
-- -- 			end,
-- -- 			description = "Format using ruby-lsp",
-- -- 		},
-- -- 	},
-- })
-- lspconfig.tsserver.setup({})
-- lspconfig.yamlls.setup({})

vim.keymap.set("n", "gf", vim.lsp.buf.format, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
