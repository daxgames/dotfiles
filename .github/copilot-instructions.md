# Copilot instructions for YADR dotfiles

This repository is a fork of [skwp/dotfiles](https://github.com/skwp/dotfiles) (YADR). It holds shared shell, git, tmux, Vim and Neovim configuration. Personal or machine-specific files live in a separate **yadr.user** repository (`~/.yadr.user`) and are symlinked into place.

## Repository layout

| Path | Purpose |
| --- | --- |
| `Rakefile`, `install.sh` | Installer. `rake install` links `~/.yadr/nvim` to `~/.config/nvim`, among others. |
| `bin/yadr/` | Helper scripts (`vimplug.rb` runs `PlugInstall`/`PlugUpdate`). |
| `nvim/init.vim` | Neovim entry point. Sources, in order: `settings/before/main.vim`, `plugins/main.vim`, `settings/main.vim`, `settings/after/main.vim`. |
| `nvim/plugins/*.vim` | vim-plug declarations (`Plug '...'`). All files are sourced between `plug#begin`/`plug#end`. |
| `nvim/settings/*.vim` | Plugin and editor settings. `plugin-<name>.vim` configures one plugin, `vim-*.vim` holds general settings. Lua settings are loaded with `lua require('settings/<name>')`. |
| `nvim/lua/settings/*.lua` | Lua configuration modules required from `nvim/settings/*.vim`. |
| `nvim/settings/before`, `nvim/settings/after` | User hooks loaded before/after the main configuration (gitignored except `main.vim`). |
| `vim/`, `zsh/`, `git/`, `tmux/` | Classic Vim, shell, git and tmux configuration. |

Leader key is `,` (set in `nvim/settings/before/000-run_first.vim`).

## User plugins (`userplugin-*`)

Files matching `*userplugin*.*` are **gitignored** in this repository. They are owned by the yadr.user repository and symlinked here by `~/.yadr.user/install.sh`, driven by the `__YADR_USER_DOTFILES` list in the profile `.conf` files (for example `~/.yadr.user/personal.conf`).

A user plugin normally consists of three files:

1. `nvim/plugins/userplugin-<name>.vim` declares the plugin with `Plug '...'`.
2. `nvim/settings/userplugin-<name>.vim` contains `lua require('settings/userplugin-<name>')`.
3. `nvim/lua/settings/userplugin-<name>.lua` holds the configuration.

To add one, create the files under `~/.yadr.user/<profile>/.config/nvim/...`, add the three paths to the profile `.conf`, and re-run `~/.yadr.user/install.sh` (or `ln -nsf` them manually). Commit those files to the yadr.user repository, not to this one.

## CopilotChat.nvim

The configuration lives in `nvim/lua/settings/plugin-copilot-chat.lua`, loaded by `nvim/settings/plugin-copilot-chat.vim`. The plugins are declared in `nvim/plugins/git.vim` (`copilot.vim`, `CopilotChat.nvim`) and `nvim/plugins/neovim.vim` (`plenary.nvim`, `telescope.nvim`/`telescope-ui-select.nvim` for pickers, `nvim-treesitter`, `render-markdown.nvim`). Personal settings belong in `~/.copilotchat.user.lua` (see below). The configuration makes CopilotChat behave like Copilot Chat in VS Code:

- **Layout:** `window` gives a narrow right-hand vertical sidebar (`width = 0.3`). `auto_insert_mode` and `insert_at_end` put the cursor in the prompt.
- **Model:** `model` (change with `,am` at runtime).
- **Context:** `resources = { 'selection', 'buffer:active' }`. Repository instructions come from the plugin's default `instruction_files` (`.github/copilot-instructions.md`, `AGENTS.md`) in the current working directory.
- **Tools:** `tools = { 'copilot', 'git_exec', 'ask_user' }`. `trusted_tools` lists read-only tools that run without approval. `edit`, `bash` and other tools still ask. Never set `trusted_tools = true`.
- **`git_exec`:** a custom trusted tool. It classifies each git command into three tiers:
  - `GIT_READ_ONLY` and read-only forms of `branch`/`tag`/`remote`/`stash` run immediately.
  - `GIT_PROMPT` verbs (commit, checkout, push, reset, rebase, ...) show a `confirm()` prompt.
  - Everything else is denied, including force pushes, `--upload-pack`/`--exec`/`--output` options, `rebase -x`, and unknown verbs.

  Commands run through `vim.system` with an argv list, never a shell. Keep destructive verbs behind the prompt when editing these tables.
- **`ask_user`:** a custom trusted tool that lets Copilot ask the user a clarifying question (`question` plus optional `guidance`). A `confirm()` prompt offers Approve / Reject / Suggest: Approve returns "proceed" without reading a separate answer, Reject returns "do not proceed" without reading one, and Suggest reads a single answer with the suggested changes. The result is returned to Copilot. Every exchange is appended as JSONL to `<history_path>/ask_user.log`; `,aA` browses it. Prompts are synchronous (like `git_exec`) so the resolver returns inside the async tool runner.
- **Readable tool calls:** the chat renderer is wrapped (`reformat_tool_calls`) so tool-call arguments display as wrapped, truncated (`MAX_INLINE_LINES`) virtual lines instead of `vim.inspect()` dumps. `,av` opens the full arguments in a markdown float. The hook depends on plugin internals (`copilot-chat-headers` namespace, `Chat:render`) and disables itself with a warning if they change.
- **History:** every response is autosaved as JSON under `history_path`. `,ah` browses and resumes sessions. `ask_user` logs to `<history_path>/ask_user.log` (`,aA` to browse).
- **Markdown:** `render-markdown.nvim` renders the `copilot-chat` and `copilot-tool-view` filetypes.
- **Keymaps:** they use the `,a` prefix (`,c*` is taken by existing mappings). The header comment of the Lua file lists them all. VS Code chords (`<C-M-i>`, `<D-i>`, `<C-S-M-l>`) are mapped too, but most terminals cannot send them. In the chat prompt (insert mode), `<Tab>` accepts the Copilot inline suggestion (from `copilot.vim`) and `<CR>` inserts a newline (or accepts the nvim-cmp popup if open); press `<Esc>` then `<CR>` in normal mode to submit the prompt.

Plugin defaults are in `~/.local/share/nvim/site/plugged/CopilotChat.nvim/lua/CopilotChat/config.lua` and `config/{mappings,functions,prompts}.lua`. Only override what differs from the defaults.

### Personal overrides (`~/.copilotchat.user.lua`)

Like `git/gitconfig`, which ends with `[include] path = .gitconfig.user`, the CopilotChat config loads an optional per-user file before calling `setup()`. The path is `~/.copilotchat.user.lua`, or `$YADR_COPILOT_CHAT_USER` if that is set. The file is listed in `~/.yadr.user/.yadr.user.files.conf`, so it lives in a yadr.user profile like `.gitconfig.user`. Don't put personal preferences in `plugin-copilot-chat.lua`.

The file can return a table, which is deep-merged over the defaults. List values such as `tools` and `resources` replace the default list instead of merging into it:

```lua
return {
  model = 'gpt-5',
  window = { width = 0.4 },
}
```

Or it can return a function that receives the full options table, edits it, and returns it. Use this form to add to a list:

```lua
return function(opts)
  table.insert(opts.trusted_tools, 'buffer')
  return opts
end
```

Errors in the file are reported with `vim.notify`, and the defaults are used. Overriding `callback` disables history autosave unless your callback also saves. Keymaps are not part of `opts`; change them in `settings/after`.

## Conventions

- Keep changes surgical and match the style of nearby files: two-space Lua indentation, single quotes in Lua, and `"` comments in Vimscript.
- Before adding a keymap, check that it is free with `:verbose map <lhs>` or by grepping `nvim/`.
- Don't commit secrets, tokens or machine-specific paths to this repository. Machine-specific configuration belongs in yadr.user.
- Update `nvim/README.md` when adding user-visible keymaps or features.

## Validation

```sh
# Load the full config headlessly and surface errors
nvim --headless +'lua print("ok")' +qa

# Install or update plugins declared in nvim/plugins/*.vim
nvim --headless +'PlugInstall --sync' +qa

# Inside Neovim
:checkhealth CopilotChat
```

The installer smoke tests live in `test/` (`test/install-smoke-test.sh`).
