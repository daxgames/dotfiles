-- CopilotChat.nvim configuration tuned to behave like Copilot Chat in VS Code.
-- Maintenance notes: ~/.yadr/.github/copilot-instructions.md
--
-- Personal overrides: create ~/.copilotchat.user.lua (or set
-- $YADR_COPILOT_CHAT_USER to another path). It is the CopilotChat equivalent
-- of ~/.gitconfig.user and can return either:
--   * a table, deep-merged over the defaults below (lists replace defaults):
--       return { model = 'gpt-5', window = { width = 0.4 } }
--   * a function(opts) that edits and/or returns the full options table:
--       return function(opts) table.insert(opts.tools, 'bash'); return opts end
-- Keep it in your yadr.user profile so ~/.yadr.user/install.sh links it.
--
-- Keymaps (leader is ","):
--   <leader>aa / <C-M-i>   toggle chat sidebar          (VS Code: Ctrl+Alt+I)
--   <leader>ai / <D-i>     inline edit (n/v)            (VS Code: Cmd+I)
--   <leader>aq             quick chat (float)           (VS Code: Shift+Alt+Ctrl+L)
--   <leader>am             model picker
--   <leader>ap             prompt/action picker
--   <leader>ah             chat history (resume)
--   <leader>aA             browse the ask_user question log
--   <leader>ae/af/ar/ao/ad/at/ac   Explain/Fix/Review/Optimize/Docs/Tests/Commit (n/v)
--   <leader>ag             open chat with the GitAssistant system prompt
-- Inside the chat buffer:
--   <Tab> (insert)         accept the Copilot inline suggestion (copilot.vim)
--   <CR> (insert)          newline (accept cmp popup if open)
--   <Esc> then <CR> (n)    submit the prompt (the current buffer contents)
--   <C-c>                  stop the running request, otherwise close
--   <leader>as             stop and steer (send extra guidance)
--   <leader>av             view tool calls in a scrollable markdown float
--   <C-y> / gR             accept / reject (undo) the suggested diff

local ok_chat, chat = pcall(require, 'CopilotChat')
if not ok_chat then
  return
end

local utils = require('CopilotChat.utils')
local constants = require('CopilotChat.constants')
local default_mappings = require('CopilotChat.config.mappings')

---------------------------------------------------------------------------
-- git_exec: trusted git tool that prompts for destructive commands
---------------------------------------------------------------------------

local GIT_READ_ONLY = {
  status = true, diff = true, log = true, show = true, fetch = true,
  blame = true, ['rev-parse'] = true, ['ls-files'] = true, shortlog = true,
  describe = true, grep = true, add = true,
}

local GIT_PROMPT = {
  commit = true, checkout = true, switch = true, reset = true, restore = true,
  rebase = true, merge = true, ['cherry-pick'] = true, pull = true, push = true,
  clean = true, revert = true, rm = true, mv = true, apply = true, am = true,
  stash = true, branch = true, tag = true, remote = true,
}

-- Options that make git execute external programs or write arbitrary files.
local GIT_DENY_OPTION_PREFIXES = { '--upload-pack', '--receive-pack', '--exec', '--output' }
local GIT_FORCE_PUSH = { ['--force'] = true, ['-f'] = true, ['--force-with-lease'] = true, ['--force-if-includes'] = true, ['--mirror'] = true }

local function git_result(uri, text)
  return { { uri = 'git://' .. uri, mimetype = 'text/plain', data = text } }
end

-- Split a command line into argv, honouring single and double quotes.
local function tokenize(s)
  local args, cur, quote, started = {}, {}, nil, false
  for ch in s:gmatch('.') do
    if quote then
      if ch == quote then
        quote = nil
      else
        cur[#cur + 1] = ch
      end
    elseif ch == '"' or ch == "'" then
      quote, started = ch, true
    elseif ch:match('%s') then
      if #cur > 0 or started then
        args[#args + 1] = table.concat(cur)
        cur, started = {}, false
      end
    else
      cur[#cur + 1] = ch
    end
  end
  if quote then
    return nil
  end
  if #cur > 0 or started then
    args[#args + 1] = table.concat(cur)
  end
  return args
end

local function has_any(args, set)
  for _, a in ipairs(args) do
    if set[a] or set[a:match('^(%-%-[^=]+)=') or ''] then
      return true
    end
  end
  return false
end

local function has_positional(args)
  for _, a in ipairs(args) do
    if not a:match('^%-') then
      return true
    end
  end
  return false
end

local LIST_QUERY_FLAGS = {
  ['-l'] = true, ['--list'] = true, ['--contains'] = true, ['--no-contains'] = true,
  ['--merged'] = true, ['--no-merged'] = true, ['--points-at'] = true,
}
local BRANCH_MUTATING = {
  ['-d'] = true, ['-D'] = true, ['--delete'] = true, ['-m'] = true, ['-M'] = true, ['--move'] = true,
  ['-c'] = true, ['-C'] = true, ['--copy'] = true, ['-f'] = true, ['--force'] = true, ['-u'] = true,
  ['--set-upstream-to'] = true, ['--unset-upstream'] = true, ['--edit-description'] = true,
  ['-t'] = true, ['--track'] = true,
}
local TAG_MUTATING = {
  ['-d'] = true, ['--delete'] = true, ['-a'] = true, ['--annotate'] = true, ['-s'] = true,
  ['--sign'] = true, ['-u'] = true, ['-f'] = true, ['--force'] = true, ['-m'] = true, ['-F'] = true,
}

-- Returns 'run' | 'prompt' | 'deny', reason
local function classify_git(verb, rest)
  for _, a in ipairs(rest) do
    for _, prefix in ipairs(GIT_DENY_OPTION_PREFIXES) do
      if a:sub(1, #prefix) == prefix then
        return 'deny', 'option "' .. a .. '" can execute programs or write files'
      end
    end
  end

  if verb == 'rebase' and has_any(rest, { ['-x'] = true }) then
    return 'deny', 'rebase -x executes arbitrary commands'
  end
  if verb == 'push' then
    if has_any(rest, GIT_FORCE_PUSH) then
      return 'deny', 'force push is not allowed'
    end
    for _, a in ipairs(rest) do
      if a:match('^%+') then
        return 'deny', 'force push refspec ("+") is not allowed'
      end
    end
  end

  if GIT_READ_ONLY[verb] then
    return 'run'
  end

  if verb == 'branch' then
    if not has_any(rest, BRANCH_MUTATING) and (not has_positional(rest) or has_any(rest, LIST_QUERY_FLAGS)) then
      return 'run'
    end
  elseif verb == 'tag' then
    if not has_any(rest, TAG_MUTATING) and (not has_positional(rest) or has_any(rest, LIST_QUERY_FLAGS)) then
      return 'run'
    end
  elseif verb == 'remote' then
    local sub = rest[1]
    if sub == nil or sub == '-v' or sub == '--verbose' or sub == 'show' or sub == 'get-url' then
      return 'run'
    end
  elseif verb == 'stash' then
    if rest[1] == 'list' or rest[1] == 'show' then
      return 'run'
    end
  end

  if GIT_PROMPT[verb] then
    return 'prompt', 'modifies the repository'
  end

  return 'deny', 'git subcommand "' .. verb .. '" is not in the allowlist'
end

local function display_argv(argv)
  return table.concat(vim.tbl_map(function(a)
    return a:match('[%s\'"]') and vim.fn.shellescape(a) or a
  end, argv), ' ')
end

local function safe_git_exec(input, source)
  local cmd = vim.trim((input and input.command) or ''):gsub('^git%s+', '')

  if cmd == '' then
    return git_result('error/empty', 'Denied: command is empty.')
  end

  -- Defence in depth: git runs without a shell, but reject shell syntax anyway.
  if cmd:find('[;&|`$<>\n]') then
    return git_result('error/unsafe-chars', 'Denied: unsafe shell characters detected.')
  end

  local args = tokenize(cmd)
  if not args or #args == 0 then
    return git_result('error/parse', 'Denied: could not parse command (unbalanced quotes?).')
  end

  local verb = args[1]
  local rest = vim.list_slice(args, 2)
  local action, reason = classify_git(verb, rest)

  if action == 'deny' then
    return git_result('error/not-allowed', 'Denied: ' .. reason .. '.')
  end

  local argv = vim.list_extend({ 'git' }, args)

  if action == 'prompt' then
    utils.schedule_main()
    local msg = string.format('Copilot wants to run a command that %s:\n\n  %s\n\nAllow?', reason, display_argv(argv))
    if vim.fn.confirm(msg, '&Yes\n&No', 2, 'Warning') ~= 1 then
      return git_result('error/user-denied', 'Denied by user: ' .. display_argv(argv))
    end
  end

  local cwd = (source and source.cwd and source.cwd()) or vim.fn.getcwd()
  local out = utils.system(argv, cwd)
  local output = vim.trim((out.stdout or '') .. (out.stderr or ''))

  return git_result('result/' .. tostring(vim.uv.hrtime()), table.concat({
    'Command: ' .. display_argv(argv),
    'Exit code: ' .. tostring(out.code),
    '',
    output ~= '' and output or '(no output)',
  }, '\n'))
end

---------------------------------------------------------------------------
-- Readable tool-call rendering
---------------------------------------------------------------------------

local MAX_INLINE_LINES = 20
local KEY_ORDER = { 'command', 'filename', 'path', 'scope', 'pattern', 'url', 'diff' }
local KEY_LANG = { command = 'bash', diff = 'diff' }
local TOOL_VIEW_KEY = '<leader>av'

local function decode_args(raw)
  if type(raw) == 'table' then
    return raw
  end
  if not raw or raw == '' then
    return {}
  end
  local ok, v = pcall(vim.json.decode, raw, { luanil = { object = true, array = true } })
  if ok and type(v) == 'table' then
    return v
  end
  return { arguments = raw }
end

local function sorted_keys(t)
  local rank = {}
  for i, k in ipairs(KEY_ORDER) do
    rank[k] = i
  end
  local keys = vim.tbl_keys(t)
  table.sort(keys, function(a, b)
    local ra, rb = rank[a] or 100, rank[b] or 100
    if ra ~= rb then
      return ra < rb
    end
    return tostring(a) < tostring(b)
  end)
  return keys
end

local function value_text(v)
  if type(v) == 'string' then
    return v
  end
  return vim.inspect(v)
end

local function is_block(text)
  return text:find('\n') ~= nil or #text > 60
end

local function wrap_line(line, width)
  width = math.max(width, 10)
  local out = {}
  while vim.fn.strdisplaywidth(line) > width do
    local head = vim.fn.strcharpart(line, 0, width)
    local sp = head:match('.*()%s')
    if sp and sp > width / 2 then
      out[#out + 1] = line:sub(1, sp - 1)
      line = line:sub(sp + 1)
    else
      out[#out + 1] = head
      line = vim.fn.strcharpart(line, width)
    end
  end
  out[#out + 1] = line
  return out
end

local function tool_call_virt_lines(tc, width)
  local vl = {}
  local function add(text, hl, indent)
    for _, l in ipairs(wrap_line(text, width - #indent)) do
      vl[#vl + 1] = { { indent .. l, hl } }
    end
  end

  add('▶ Tool call: ' .. tc.name, 'CopilotChatAnnotationHeader', '')
  local args = decode_args(tc.arguments)
  for _, k in ipairs(sorted_keys(args)) do
    local text = value_text(args[k])
    if is_block(text) then
      add(k .. ':', 'Identifier', '  ')
      vl[#vl + 1] = { { '  ```' .. (KEY_LANG[k] or ''), 'Comment' } }
      local body = vim.split(text, '\n', { plain = true })
      for i, l in ipairs(body) do
        if i > MAX_INLINE_LINES then
          add(string.format('… %d more lines (%s for full view)', #body - MAX_INLINE_LINES, TOOL_VIEW_KEY), 'Comment', '  ')
          break
        end
        add(l, 'CopilotChatAnnotation', '  ')
      end
      vl[#vl + 1] = { { '  ```', 'Comment' } }
    else
      add(k .. ': ' .. text, 'CopilotChatAnnotation', '  ')
    end
  end
  return vl
end

local function tool_call_markdown(tc)
  local lines = { '## Tool call: `' .. tc.name .. '`', '' }
  local args = decode_args(tc.arguments)
  for _, k in ipairs(sorted_keys(args)) do
    local text = value_text(args[k])
    if is_block(text) then
      vim.list_extend(lines, { '**' .. k .. ':**', '', '```' .. (KEY_LANG[k] or '') })
      vim.list_extend(lines, vim.split(text, '\n', { plain = true }))
      vim.list_extend(lines, { '```', '' })
    else
      lines[#lines + 1] = '- **' .. k .. ':** `' .. text .. '`'
    end
  end
  lines[#lines + 1] = ''
  return lines
end

-- Replace the plugin's vim.inspect() virtual lines with wrapped, readable ones.
local function reformat_tool_calls(self)
  if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
    return
  end
  local ns = vim.api.nvim_create_namespace('copilot-chat-headers')
  local width = 80
  if self.winnr and vim.api.nvim_win_is_valid(self.winnr) then
    local info = vim.fn.getwininfo(self.winnr)[1]
    width = vim.api.nvim_win_get_width(self.winnr) - ((info and info.textoff) or 0) - 1
  end

  local messages = self:get_messages()
  -- The plugin renders arguments with vim.inspect(); use that text to map an
  -- extmark back to its tool call.
  local by_inspect = {}
  for _, m in ipairs(messages) do
    for _, tc in ipairs(m.tool_calls or {}) do
      if not utils.empty(tc.arguments) then
        local ok, text = pcall(function()
          return vim.inspect(utils.json_decode(tc.arguments))
        end)
        if ok then
          by_inspect[text] = tc
        end
      end
    end
  end

  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(self.bufnr, ns, 0, -1, { details = true })) do
    local id, row, d = mark[1], mark[2], mark[4]
    local first = d.virt_lines and d.virt_lines[1] and d.virt_lines[1][1] and d.virt_lines[1][1][1]
    if first == 'Tool calls:' then
      for _, m in ipairs(messages) do
        if m.tool_calls and #m.tool_calls > 0 and m.section and m.section.end_line == row + 1 then
          local vl = {}
          for _, tc in ipairs(m.tool_calls) do
            vim.list_extend(vl, tool_call_virt_lines(tc, width))
          end
          vim.api.nvim_buf_set_extmark(self.bufnr, ns, row, 0, {
            id = id, virt_lines = vl, virt_lines_above = true, priority = 100, strict = false,
          })
        end
      end
    elseif first and not d.virt_lines_above then
      local text = table.concat(vim.tbl_map(function(l)
        return l[1] and l[1][1] or ''
      end, d.virt_lines), '\n')
      local tc = by_inspect[text]
      if tc then
        vim.api.nvim_buf_set_extmark(self.bufnr, ns, row, 0, {
          id = id, virt_lines = tool_call_virt_lines(tc, width), priority = 100, strict = false,
        })
      end
    end
  end
end

local function show_tool_calls()
  local c = chat.chat
  local msg = c:get_message(constants.ROLE.ASSISTANT, true)
  if not (msg and msg.tool_calls and #msg.tool_calls > 0) then
    msg = c:get_message(constants.ROLE.ASSISTANT)
  end
  if not (msg and msg.tool_calls and #msg.tool_calls > 0) then
    vim.notify('No tool calls in the current response', vim.log.levels.INFO)
    return
  end

  local lines = { '# Tool calls', '' }
  for _, tc in ipairs(msg.tool_calls) do
    vim.list_extend(lines, tool_call_markdown(tc))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'copilot-tool-view'

  local w = math.floor(vim.o.columns * 0.8)
  local h = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor', width = w, height = h,
    row = math.floor((vim.o.lines - h) / 2), col = math.floor((vim.o.columns - w) / 2),
    border = 'rounded', title = ' Tool calls (q to close) ', title_pos = 'center',
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].conceallevel = 2
  for _, key in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', key, function()
      pcall(vim.api.nvim_win_close, win, true)
    end, { buffer = buf, nowait = true })
  end
end

vim.treesitter.language.register('markdown', 'copilot-tool-view')

---------------------------------------------------------------------------
-- History: autosave every response, browse and resume
---------------------------------------------------------------------------

local session = { name = nil, first = nil }

local function history_dir()
  return vim.fs.normalize(chat.config.history_path)
end

local function save_history()
  local c = chat.chat
  local msgs = c and c:get_messages() or {}
  if #msgs < 2 then
    return
  end
  if session.first ~= msgs[1].content or not session.name then
    session.name = os.date('%Y-%m-%d_%H%M%S')
    session.first = msgs[1].content
  end
  local history = vim.deepcopy(msgs)
  for _, m in ipairs(history) do
    m.section = nil
  end
  vim.fn.mkdir(history_dir(), 'p')
  local f = io.open(history_dir() .. '/' .. session.name .. '.json', 'w')
  if f then
    f:write(vim.json.encode(history))
    f:close()
  end
end

local function history_preview(path)
  local f = io.open(path, 'r')
  if not f then
    return ''
  end
  local ok, data = pcall(vim.json.decode, f:read('*a'))
  f:close()
  if not ok or type(data) ~= 'table' then
    return ''
  end
  for _, m in ipairs(data) do
    if m.role == constants.ROLE.USER and m.content then
      local text = m.content:gsub('^%s*>[^\n]*\n', ''):gsub('%s+', ' ')
      return vim.trim(text):sub(1, 80)
    end
  end
  return ''
end

local function pick_history()
  local dir = history_dir()
  local items = {}
  for name, type in vim.fs.dir(dir) do
    if type == 'file' and name:match('%.json$') then
      local path = dir .. '/' .. name
      local stat = vim.uv.fs_stat(path)
      items[#items + 1] = { name = name:gsub('%.json$', ''), path = path, mtime = stat and stat.mtime.sec or 0 }
    end
  end
  if #items == 0 then
    vim.notify('No CopilotChat history in ' .. dir, vim.log.levels.INFO)
    return
  end
  table.sort(items, function(a, b)
    return a.mtime > b.mtime
  end)
  vim.ui.select(items, {
    prompt = 'Copilot chat history> ',
    format_item = function(item)
      return item.name .. '  ' .. history_preview(item.path)
    end,
  }, function(choice)
    if not choice then
      return
    end
    chat.open()
    chat.load(choice.name)
    local msgs = chat.chat:get_messages()
    session.name = choice.name
    session.first = msgs[1] and msgs[1].content
  end)
end

---------------------------------------------------------------------------
-- ask_user: trusted tool that relays a question from Copilot to the user
---------------------------------------------------------------------------
-- Copilot calls this when it needs clarification. The user can Approve (go
-- ahead, no answer needed), Reject (do not do it, no answer needed), or
-- Suggest (provide a single answer with suggested changes). Every exchange is
-- appended to a JSONL log under <history_path>/ask_user.log for later reference.

local function ask_user_log_path()
  return history_dir() .. '/ask_user.log'
end

local function log_ask_user(entry)
  vim.fn.mkdir(history_dir(), 'p')
  local f = io.open(ask_user_log_path(), 'a')
  if f then
    f:write(vim.json.encode(entry) .. '\n')
    f:close()
  end
end

local function ask_user_result(uri, text)
  return { { uri = 'ask_user://' .. uri, mimetype = 'text/plain', data = text } }
end

local function safe_ask_user(input, _source)
  local question = vim.trim((input and input.question) or '')
  if question == '' then
    return ask_user_result('error/empty', 'Denied: question is empty.')
  end
  local guidance = vim.trim((input and input.guidance) or '')

  utils.schedule_main()

  -- Synchronous prompts (like git_exec's confirm) so the tool resolver can
  -- return a value directly inside CopilotChat's async tool runner.
  local prompt = 'Copilot is asking a question:\n\n  ' .. question:gsub('\n', '\n  ')
  if guidance ~= '' then
    prompt = prompt .. '\n\nGuidance on how to answer:\n\n  ' .. guidance:gsub('\n', '\n  ')
  end
  prompt = prompt
    .. '\n\nApprove (proceed), Reject (do not proceed), or Suggest (answer with changes)?'
    .. '\n(Suggest then prompts for one line: type your answer and press <Enter> to submit, <Esc> to cancel.)'

  local timestamp = os.date('%Y-%m-%dT%H:%M:%S')
  local pick = vim.fn.confirm(prompt, '&Approve\n&Reject\n&Suggest', 1, 'Question')

  -- Approve: proceed, no separate answer requested.
  if pick == 1 then
    log_ask_user({ time = timestamp, question = question, guidance = guidance, approved = true, response = '', note = 'approved' })
    return ask_user_result('approved/' .. tostring(vim.uv.hrtime()), 'User approved: proceed.')
  end

  -- Reject (or cancel/Esc): do not proceed, no separate answer requested.
  if pick == 0 or pick == 2 then
    log_ask_user({ time = timestamp, question = question, guidance = guidance, approved = false, response = '', note = 'rejected' })
    return ask_user_result('rejected/' .. tostring(vim.uv.hrtime()), 'User rejected: do not proceed.')
  end

  -- Suggest: ask for a single answer with the suggested changes.
  local reply = vim.trim(vim.fn.input({ prompt = 'Your suggestion (<Enter> submit, <Esc> cancel): ', cancelreturn = '' }) or '')
  log_ask_user({ time = timestamp, question = question, guidance = guidance, approved = true, response = reply, note = 'suggested' })
  if reply == '' then
    return ask_user_result('suggested/empty', 'User chose Suggest but did not provide any changes.')
  end
  return ask_user_result('suggested/' .. tostring(vim.uv.hrtime()), 'User suggestion: ' .. reply)
end

local function pick_ask_user_log()
  local path = ask_user_log_path()
  local f = io.open(path, 'r')
  if not f then
    vim.notify('No ask_user log at ' .. path, vim.log.levels.INFO)
    return
  end
  local entries = {}
  for line in f:lines() do
    local ok, entry = pcall(vim.json.decode, line)
    if ok and type(entry) == 'table' then
      entries[#entries + 1] = entry
    end
  end
  f:close()
  if #entries == 0 then
    vim.notify('ask_user log is empty: ' .. path, vim.log.levels.INFO)
    return
  end
  local reversed = {}
  for i = #entries, 1, -1 do
    reversed[#reversed + 1] = entries[i]
  end
  vim.ui.select(reversed, {
    prompt = 'ask_user log> ',
    format_item = function(e)
      local status = e.approved and '✓' or '✗'
      return string.format('%s %s  %s', status, e.time or '?', (e.question or ''):gsub('%s+', ' '):sub(1, 70))
    end,
  }, function(choice)
    if not choice then
      return
    end
    local lines = {
      '# ask_user entry',
      '',
      '- **time:** ' .. tostring(choice.time),
      '- **approved:** ' .. tostring(choice.approved),
      '',
      '## Question',
      '',
    }
    vim.list_extend(lines, vim.split(choice.question or '', '\n', { plain = true }))
    if choice.guidance and choice.guidance ~= '' then
      vim.list_extend(lines, { '', '## Guidance', '' })
      vim.list_extend(lines, vim.split(choice.guidance, '\n', { plain = true }))
    end
    vim.list_extend(lines, { '', '## Response', '' })
    vim.list_extend(lines, vim.split(choice.response or '', '\n', { plain = true }))

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = 'copilot-tool-view'
    local w = math.floor(vim.o.columns * 0.6)
    local h = math.floor(vim.o.lines * 0.6)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor', width = w, height = h,
      row = math.floor((vim.o.lines - h) / 2), col = math.floor((vim.o.columns - w) / 2),
      border = 'rounded', title = ' ask_user entry (q to close) ', title_pos = 'center',
    })
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true
    for _, key in ipairs({ 'q', '<Esc>' }) do
      vim.keymap.set('n', key, function()
        pcall(vim.api.nvim_win_close, win, true)
      end, { buffer = buf, nowait = true })
    end
  end)
end

---------------------------------------------------------------------------
-- Helpers for keymaps
---------------------------------------------------------------------------

local function leave_visual()
  if vim.fn.mode():match('^[vV\22]') then
    vim.cmd('normal! \27')
    return true
  end
  return false
end

local function is_running()
  return require('CopilotChat.client').current_job ~= nil
end

local function ask_input(prompt_label, config, prefix)
  vim.ui.input({ prompt = prompt_label }, function(input)
    if input and vim.trim(input) ~= '' then
      chat.ask((prefix or '') .. input, config)
    end
  end)
end

local function inline_edit()
  local had_selection = leave_visual()
  local prefix = had_selection
      and 'Edit the selected code as follows. Reply with a single code block that replaces the selection.\n\n'
    or 'Edit the active buffer as follows. Reply with code blocks covering only the changed lines.\n\n'
  ask_input('Copilot edit: ', {
    window = {
      layout = 'float', relative = 'cursor', border = 'rounded',
      width = math.min(100, math.floor(vim.o.columns * 0.6)), height = math.floor(vim.o.lines * 0.4),
      row = 1, col = 0, title = ' Copilot edit (<C-y> accept, gR reject, q close) ',
    },
  }, prefix)
end

local function quick_chat()
  leave_visual()
  ask_input('Quick chat: ', {
    window = {
      layout = 'float', relative = 'editor', border = 'rounded',
      width = 0.6, height = 0.6, title = ' Quick Chat ',
    },
  })
end

local function stop_or_close()
  if is_running() then
    chat.stop()
  else
    chat.close()
  end
end

local function steer()
  if is_running() then
    chat.stop()
  end
  ask_input('Additional guidance: ')
end

local last_accept = nil

local function reject_diff()
  if not (last_accept and vim.api.nvim_buf_is_valid(last_accept)) then
    vim.notify('No accepted Copilot diff to reject', vim.log.levels.INFO)
    return
  end
  vim.api.nvim_buf_call(last_accept, function()
    vim.cmd('silent undo')
  end)
  last_accept = nil
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------

local opts = {
  model = 'claude-opus-4.8',
  tools = { 'copilot', 'git_exec', 'ask_user' },
  -- edit/bash/url/etc. from the "copilot" group still require approval.
  trusted_tools = { 'file', 'glob', 'grep', 'gitdiff', 'ask_user' },
  -- Like VS Code: include the selection and the active editor as context.
  resources = { 'selection', 'buffer:active' },
  auto_insert_mode = true,
  insert_at_end = true,
  -- VS Code-like sidebar: narrow, full-height vertical split.
  window = {
    layout = 'vertical',
    width = 0.3,
  },
  callback = function()
    vim.schedule(save_history)
  end,
  mappings = {
    complete = {
      insert = '<C-j>',
    },
    -- <C-c> is handled below (stop if running, otherwise close).
    close = {
      normal = 'q',
      insert = '',
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>',
      callback = function(source)
        default_mappings.accept_diff.callback(source)
        last_accept = source and source.bufnr
      end,
    },
  },
  functions = {
    git_exec = {
      description = 'Run a git command in the current repo (without the leading "git"). Read-only commands run immediately; '
        .. 'commands that modify the repository ask the user for approval; force pushes and unknown subcommands are denied.',
      trusted = true,
      schema = {
        type = 'object',
        required = { 'command' },
        properties = {
          command = {
            type = 'string',
            description = 'Git command without the leading git, for example: status -sb',
          },
        },
      },
      resolve = safe_git_exec,
    },
    ask_user = {
      description = 'Ask the user a clarifying question and wait for their decision. The user can Approve (proceed), '
        .. 'Reject (do not proceed), or Suggest (proceed with the changes they provide). Use this when you need a '
        .. 'decision or missing information before continuing.',
      trusted = true,
      schema = {
        type = 'object',
        required = { 'question' },
        properties = {
          question = {
            type = 'string',
            description = 'The question to ask the user.',
          },
          guidance = {
            type = 'string',
            description = 'Optional guidance on how the user should answer (options, format, constraints).',
          },
        },
      },
      resolve = safe_ask_user,
    },
  },
  prompts = {
    GitAssistant = {
      system_prompt = 'Use git_exec for git operations. Prefer read-only commands first. Ask before destructive intent.',
      description = 'Git helper with prompted tool execution',
    },
  },
}

---------------------------------------------------------------------------
-- User overrides (like [include] path = .gitconfig.user in git/gitconfig)
---------------------------------------------------------------------------

-- Like vim.tbl_deep_extend('force'), but list values (tools, resources, ...)
-- replace the default list instead of being merged index by index.
local function merge(base, override)
  if type(base) ~= 'table' or type(override) ~= 'table' or vim.islist(override) then
    return override
  end
  local out = vim.deepcopy(base)
  for k, v in pairs(override) do
    out[k] = merge(out[k], v)
  end
  return out
end

local user_config = vim.env.YADR_COPILOT_CHAT_USER or (vim.env.HOME .. '/.copilotchat.user.lua')
if vim.uv.fs_stat(user_config) then
  local ok, user = pcall(dofile, user_config)
  if not ok then
    vim.notify('CopilotChat: error in ' .. user_config .. ': ' .. tostring(user), vim.log.levels.ERROR)
  elseif type(user) == 'function' then
    local ok_fn, result = pcall(user, opts)
    if not ok_fn then
      vim.notify('CopilotChat: error in ' .. user_config .. ': ' .. tostring(result), vim.log.levels.ERROR)
    elseif type(result) == 'table' then
      opts = result
    end
  elseif type(user) == 'table' then
    opts = merge(opts, user)
  elseif user ~= nil then
    vim.notify('CopilotChat: ' .. user_config .. ' must return a table or a function', vim.log.levels.WARN)
  end
end

chat.setup(opts)

-- Hook the chat renderer to reformat tool-call arguments. Falls back to the
-- plugin's default rendering if plugin internals change.
do
  local c = chat.chat
  local orig_render = c and c.render
  if orig_render then
    c.render = function(self, ...)
      orig_render(self, ...)
      local ok, err = pcall(reformat_tool_calls, self)
      if not ok then
        vim.notify_once('CopilotChat tool-call formatter disabled: ' .. tostring(err), vim.log.levels.WARN)
        c.render = orig_render
      end
    end
  end
end

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------

local function map(modes, lhs_list, rhs, desc)
  for _, lhs in ipairs(lhs_list) do
    vim.keymap.set(modes, lhs, rhs, { desc = desc, silent = true })
  end
end

map({ 'n', 'v' }, { '<leader>aa', '<C-M-i>', '<C-D-i>' }, chat.toggle, 'Copilot Chat: toggle sidebar')
map({ 'n', 'v' }, { '<leader>ai', '<D-i>' }, inline_edit, 'Copilot Chat: inline edit')
map({ 'n', 'v' }, { '<leader>aq', '<C-S-M-l>' }, quick_chat, 'Copilot Chat: quick chat')
map('n', { '<leader>am' }, chat.select_model, 'Copilot Chat: select model')
map({ 'n', 'v' }, { '<leader>ap' }, function()
  leave_visual()
  chat.select_prompt()
end, 'Copilot Chat: select prompt')
map('n', { '<leader>ah' }, pick_history, 'Copilot Chat: history')
map('n', { '<leader>aA' }, pick_ask_user_log, 'Copilot Chat: ask_user log')
map('n', { '<leader>ag' }, function()
  chat.open({ sticky = { '/GitAssistant', '@git_exec' } })
end, 'Copilot Chat: git assistant')

for lhs, name in pairs({
  ['<leader>ae'] = 'Explain',
  ['<leader>af'] = 'Fix',
  ['<leader>ar'] = 'Review',
  ['<leader>ao'] = 'Optimize',
  ['<leader>ad'] = 'Docs',
  ['<leader>at'] = 'Tests',
  ['<leader>ac'] = 'Commit',
}) do
  map({ 'n', 'v' }, { lhs }, function()
    leave_visual()
    vim.cmd('CopilotChat' .. name)
  end, 'Copilot Chat: ' .. name)
end

function _G.CopilotChatInsertCR()
  if vim.fn.pumvisible() == 1 then
    return vim.keycode('<C-y>')
  end
  return vim.keycode('<CR>')
end

local group = vim.api.nvim_create_augroup('UserCopilotChat', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'copilot-chat',
  callback = function(ev)
    local opts = function(desc)
      return { buffer = ev.buf, silent = true, desc = desc }
    end
    vim.keymap.set({ 'n', 'i' }, '<C-c>', stop_or_close, opts('Copilot Chat: stop or close'))
    vim.keymap.set('n', '<leader>as', steer, opts('Copilot Chat: stop and steer'))
    vim.keymap.set('n', TOOL_VIEW_KEY, show_tool_calls, opts('Copilot Chat: view tool calls'))
    vim.keymap.set('n', 'gR', reject_diff, opts('Copilot Chat: reject (undo) accepted diff'))
    -- Insert-mode <CR> inserts a newline so multi-line prompts are easy to
    -- write; leave insert mode (<Esc>) and press <CR> in normal mode to submit
    -- (the plugin's default submit_prompt normal-mode mapping). Avoids <C-s>,
    -- which many terminals swallow as XOFF flow control.
    -- String rhs (not a Lua callback) so auto-pairs can inspect the mapping.
    vim.keymap.set('i', '<CR>', 'v:lua.CopilotChatInsertCR()', vim.tbl_extend('force', opts('Copilot Chat: newline or accept completion'), { expr = true }))
  end,
})

-- Re-wrap tool-call annotations when the sidebar is resized.
vim.api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
  group = group,
  callback = function()
    local c = chat.chat
    if c and c:visible() and not is_running() then
      pcall(c.render, c)
    end
  end,
})

---------------------------------------------------------------------------
-- Markdown rendering in the chat and tool-call view
---------------------------------------------------------------------------

local ok_rm, render_markdown = pcall(require, 'render-markdown')
if ok_rm then
  render_markdown.setup({
    file_types = { 'copilot-chat', 'copilot-tool-view' },
    render_modes = true,
    -- Render heading icons inline instead of overlaying them on the '# '
    -- markers; overlay bled onto the first character of the header text
    -- (e.g. "Copilot" -> "opilot", "Tool call" -> "ool call"). Pad the icons
    -- with a leading space so they do not sit flush against the heading text.
    heading = {
      position = 'inline',
      icons = { ' 󰲡 ', ' 󰲣 ', ' 󰲥 ', ' 󰲧 ', ' 󰲩 ', ' 󰲫 ' },
    },
  })
end
