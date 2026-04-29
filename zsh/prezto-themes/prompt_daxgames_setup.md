# Prompt Configuration Explanation: prompt_daxgames_setup

This is a Zsh prompt configuration file for the **Prezto framework**. It defines how your terminal prompt looks and behaves. The prompt is based on the Sorin theme and has been customized to show Git information on the left, Git worktree/repository names, and Ruby version information on the right.

## Header Comments (Lines 1-10)

```
#
# A theme based on sorin theme
#  * ruby info shown on the right
#  * git info on the left
#  * editor mode as $> or <#
#  * single line prompt
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Kyle West <kswest@gmail.com>
#   Dax Games <dtgames@kinggeek.org>
```

These are documentation comments describing the theme's features and authorship. They explain:
- The theme is based on the "sorin" theme
- Ruby version info appears on the right side of the prompt (RPROMPT)
- Git repository info appears on the left side of the prompt
- The editor mode shows `$>` for insert mode or `<#` for normal mode (Vi keybinding modes)
- The prompt is single-line (not multi-line)

---

## Precmd Hook Function (Lines 13-32)

```zsh
function prompt_daxgames_precmd {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
```

**`function prompt_daxgames_precmd`**: Defines a function that runs automatically before each command prompt appears. This is a "precmd" hook function, meaning it executes right before the shell displays your prompt.

**`setopt LOCAL_OPTIONS`**: Enables local shell options for this function only. Any option changes made within this function won't affect the global shell options.

**`unsetopt XTRACE KSH_ARRAYS`**: Disables two shell options:
- `XTRACE`: Prevents verbose debugging output from being printed
- `KSH_ARRAYS`: Prevents the shell from using Korn shell array behavior (keeps Zsh's native array handling)

```zsh
  # Get Git repository information.
  if (( $+functions[git-info] )); then
    git-info on
    git-info
  fi
```

**`if (( $+functions[git-info] ))`**: Checks if the `git-info` function exists. The `$+functions[git-info]` syntax returns 1 if the function exists, 0 if it doesn't. The `(( ... ))` evaluates it as a boolean.

**`git-info on`**: Enables the git-info functionality.

**`git-info`**: Calls the function to gather current Git repository information (branch name, dirty status, etc.) and stores it in the `git_info` array.

```zsh
  # Get ruby information
  if (( $+functions[ruby-info] )); then
    ruby-info
  fi
```

**`if (( $+functions[ruby-info] ))`**: Checks if the `ruby-info` function exists (similar to the git-info check above).

**`ruby-info`**: Calls the function to gather Ruby version information (from RVM or rbenv) and stores it in the `ruby_info` array.

```zsh
  # Get worktree-aware directory name
  prompt_dir=$(git remote -v| head -n1 | awk '{print$2}' | awk -F'/' '{print $NF}' 2>/dev/null)
  prompt_dir=$(pwd | grep -o "/${prompt_dir}[.A-Za-z]*/*" | sed 's/\///;s/\/$//')
}
```

**Worktree-aware directory name section**: This logic extracts a meaningful directory name from the repository structure. It breaks down as follows:

**Line 1 of worktree logic**: `prompt_dir=$(git remote -v| head -n1 | awk '{print$2}' | awk -F'/' '{print $NF}' 2>/dev/null)`
- `git remote -v`: Lists all git remotes with their URLs (verbose)
- `head -n1`: Takes only the first line (typically "origin")
- `awk '{print$2}'`: Extracts the URL (second column)
- `awk -F'/' '{print $NF}'`: Splits by `/` and takes the last part (repository name)
- `2>/dev/null`: Suppresses error messages if not in a git repository
- **Result**: Extracts the repository name from the git remote URL (e.g., `my-repo.git` from `https://github.com/user/my-repo.git`)

**Line 2 of worktree logic**: `prompt_dir=$(pwd | grep -o "/${prompt_dir}[.A-Za-z]*/*" | sed 's/\///;s/\/$//')`
- `pwd`: Gets the current working directory
- `grep -o "/${prompt_dir}[.A-Za-z]*/*"`: Searches for the repository name (with optional extensions like `.git`) in the path
- `sed 's/\///;s/\/$//'`: Removes leading and trailing slashes
- **Result**: Extracts just the repository/worktree directory name from your full path (e.g., from `/Users/me/projects/my-repo/src`, extracts `my-repo`)

**`}`**: Closes the precmd hook function.

---

## Setup Function (Lines 34-70)

```zsh
function prompt_daxgames_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
```

**`function prompt_daxgames_setup`**: Defines the main setup function that initializes and configures the entire prompt. Prezto calls this function when loading the theme.

**`setopt LOCAL_OPTIONS` and `unsetopt XTRACE KSH_ARRAYS`**: Same as in the precmd function—sets up a clean local environment for option changes.

```zsh
  prompt_opts=(cr percent subst)
```

**`prompt_opts`**: A Zsh array that controls prompt expansion behavior:
- `cr`: Recognize the special handling of `%` in the prompt string
- `percent`: Enable percent escape sequences (like `%c` for current directory)
- `subst`: Enable parameter/command substitution in the prompt

```zsh
  # Load required functions.
  autoload -Uz add-zsh-hook
```

**`autoload -Uz add-zsh-hook`**: Loads the `add-zsh-hook` utility function from Zsh. The flags mean:
- `-U`: Unaliased (treat as a function, not an alias)
- `-z`: Use Zsh style (not POSIX)

This function allows you to add functions to Zsh hooks (like precmd).

```zsh
  # Add hook for calling git-info before each command.
  add-zsh-hook precmd prompt_daxgames_precmd

  # Initialize worktree-aware directory variable
  prompt_dir="%c"
```

**`add-zsh-hook precmd prompt_daxgames_precmd`**: Registers the `prompt_daxgames_precmd` function to run automatically before each prompt is displayed. This is what makes Git and Ruby info update dynamically.

**`prompt_dir="%c"`**: Initializes the `prompt_dir` variable with a default value of the current directory. This variable gets updated by the precmd hook with the extracted repository/worktree name.

---

## Editor Mode Styling (Lines 48-50)

```zsh
  # editor
  zstyle ':prezto:module:editor:info:completing' format '%B%F{red}...%f%b'
  zstyle ':prezto:module:editor:info:keymap:primary' format "%B%F{green}$>%f%b"
  zstyle ':prezto:module:editor:info:keymap:alternate' format "%B%F{magenta}<#%f%b"
```

**`zstyle`**: Sets styling/configuration values for Prezto modules. Think of it like CSS for Zsh.

**`:prezto:module:editor:info:completing`**: Configuration for the "completing" editor state (when you're in the middle of completing a command).
- `'%B%F{red}...%f%b'` format: Bold, `...` in red, reset color, unbold

**`:prezto:module:editor:info:keymap:primary`**: Configuration for insert mode (the primary/default keymap).
- Shows `$>` in bold green

**`:prezto:module:editor:info:keymap:alternate`**: Configuration for normal/command mode (alternate keymap in Vi mode).
- Shows `<#` in bold magenta

---

## Ruby Version Styling (Line 52)

```zsh
  # ruby info (rvm, rbenv)
  zstyle ':prezto:module:ruby:info:version' format '[ %v ]'
```

**`:prezto:module:ruby:info:version`**: Configuration for how Ruby version info is displayed.
- `'[ %v ]'` format: Displays Ruby version surrounded by square brackets with spaces (e.g., `[ 3.2.0 ]`)
- `%v` is a placeholder for the actual version number

---

## Git Styling (Lines 54-56)

```zsh
  # vcs
  zstyle ':prezto:module:git:info:branch' format '%F{yellow}%b%f'
  zstyle ':prezto:module:git:info:dirty' format '%B%F{red}!%f%b'
  zstyle ':prezto:module:git:info:keys' format 'prompt' '- %b%D '
```

**`:prezto:module:git:info:branch`**: Configuration for how the Git branch name appears.
- `'%F{yellow}%b%f'` format: Yellow color, branch name (`%b`), reset color

**`:prezto:module:git:info:dirty`**: Configuration for showing when a Git repository has uncommitted changes.
- `'%B%F{red}!%f%b'` format: Bold, red color, exclamation mark (`!`), reset color, unbold

**`:prezto:module:git:info:keys`**: Defines the Git info segments and how they're combined for the prompt.
- `'prompt'`: The key name used to store the formatted Git information
- `'- %b%D '` format: Displays as "- " followed by branch name (`%b`), dirty indicator (`%D`), and a space

---

## Prompt Definitions (Lines 58-60)

```zsh
  # prompts
  PROMPT='${prompt_dir} ${git_info[prompt]}${editor_info[keymap]} '
  RPROMPT='%F{blue}${ruby_info[version]}'
```

**`PROMPT`**: Defines the main left-aligned prompt displayed before each command. This is what you see when you type.

Components:
- `${prompt_dir}`: The dynamically-extracted repository/worktree name (set by the precmd hook)
- `${git_info[prompt]}`: Insert the formatted Git information (branch and dirty status)
- `${editor_info[keymap]}`: Insert the editor mode indicator (`$>` or `<#`)
- ` ` (space): Add a space before the cursor

**Example output**: `my-repo - main $> `

**`RPROMPT`**: Defines the right-aligned prompt (shown at the end of the same line).

Components:
- `%F{blue}`: Set color to blue
- `${ruby_info[version]}`: Insert the Ruby version info (e.g., `[ 3.2.0 ]`)

**Example output**: `[ 3.2.0 ]`

---

## Function Invocation (Line 62)

```zsh
prompt_daxgames_setup "$@"
```

**`prompt_daxgames_setup "$@"`**: Calls the setup function immediately with any arguments passed to this theme file. This initializes the prompt when Prezto loads this theme.

**`"$@"`**: Passes along any command-line arguments received by the script.

---

## Visual Example

When everything is working together, your prompt might look like:

```
my-repo - main $> █                                         [ 3.2.0 ]
```

Where:
- `my-repo` = your repository name (extracted from the git remote)
- `- main` = Git branch name (in yellow) 
- `!` = dirty indicator if you have uncommitted changes (in red, bold) - not shown in this example
- `$>` = editor mode indicator (in green for insert mode, magenta for normal mode)
- `[ 3.2.0 ]` = Ruby version (in blue, right-aligned)
- `█` = your cursor

### With uncommitted changes:

```
my-repo - main ! $> █                                       [ 3.2.0 ]
```

The `!` appears between the branch name and editor mode when you have uncommitted changes.
