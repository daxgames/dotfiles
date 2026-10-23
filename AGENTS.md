# AGENTS.md

Instructions for AI coding agents working on this repository. The full guide is [`.github/copilot-instructions.md`](.github/copilot-instructions.md). Read it before making changes.

## Quick facts

- YADR dotfiles: shared shell, git, tmux, Vim and Neovim configuration. `~/.config/nvim` is a symlink to `nvim/` in this repository.
- Neovim uses vim-plug. Plugins are declared in `nvim/plugins/*.vim`, configured in `nvim/settings/*.vim` and `nvim/lua/settings/*.lua`. Leader is `,`.
- `*userplugin*.*` files are gitignored here. They are symlinks into the separate `~/.yadr.user` repository and must be edited and committed there.
- The CopilotChat.nvim configuration is `nvim/lua/settings/plugin-copilot-chat.lua`, part of this repository. Its design (VS Code-like keymaps, `git_exec` safety tiers, tool-call rendering) is documented in the full guide. In the chat prompt, insert-mode `<Tab>` accepts the Copilot inline suggestion and `<CR>` inserts a newline; `<Esc>` then `<CR>` in normal mode submits. The `ask_user` tool prompts Approve / Reject / Suggest: Approve proceeds, Reject declines, and Suggest asks for a single answer with the suggested changes. Personal settings belong in `~/.copilotchat.user.lua` (the equivalent of `~/.gitconfig.user`), not in the shared file.

## Rules

- Make minimal, surgical edits and follow the existing file style.
- Never set CopilotChat `trusted_tools = true`. Keep destructive git verbs in the `git_exec` prompt tier.
- Don't commit secrets or machine-specific paths.
- Check keymaps for conflicts before adding them.

## Validate

```sh
nvim --headless +'lua print("ok")' +qa
nvim --headless +'PlugInstall --sync' +qa
```

Then run `:checkhealth CopilotChat` inside Neovim.
