-- Workaround for neovim 0.12+ / VS Code terminal bug where Shift+0-9 produces
-- digits instead of !@#$%^&*(). See https://github.com/neovim/neovim/issues/38651
-- Remove this block once VS Code ships the xterm.js fix (xtermjs/xterm.js#5791).
if vim.env.TERM_PROGRAM == 'vscode' then
  local shifted_digits = {
    ['<S-1>'] = '!',
    ['<S-2>'] = '@',
    ['<S-3>'] = '#',
    ['<S-4>'] = '$',
    ['<S-5>'] = '%',
    ['<S-6>'] = '^',
    ['<S-7>'] = '&',
    ['<S-8>'] = '*',
    ['<S-9>'] = '(',
    ['<S-0>'] = ')',
  }

  for lhs, rhs in pairs(shifted_digits) do
    vim.keymap.set({ 'n', 'x', 'i' }, lhs, rhs, { noremap = true, silent = true })
    vim.keymap.set('c', lhs, function()
      return rhs
    end, { expr = true, noremap = true })
  end
end

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

local ok_oil, oil = pcall(require, 'oil')

if ok_oil then
  oil.setup({
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
  })

  map('n', '<Leader>n', '<Cmd>Oil<CR>', 'Open parent directory')
end

local ok_fzf, fzf = pcall(require, 'fzf-lua')

if ok_fzf then
  fzf.setup({
    winopts = {
      height = 0.85,
      width = 0.90,
    },
  })

  map('n', '<Leader>ff', fzf.files, 'Find files')
  map('n', '<Leader>fg', fzf.live_grep, 'Live grep')
  map('n', '<Leader>fb', fzf.buffers, 'Find buffers')
  map('n', '<Leader>fh', fzf.help_tags, 'Help tags')
end

local ok_gitsigns, gitsigns = pcall(require, 'gitsigns')

if ok_gitsigns then
  gitsigns.setup({
    current_line_blame = false,
    signs_staged_enable = true,
  })

  map('n', ']h', gitsigns.next_hunk, 'Next git hunk')
  map('n', '[h', gitsigns.prev_hunk, 'Previous git hunk')
  map('n', '<Leader>hp', gitsigns.preview_hunk, 'Preview git hunk')
  map('n', '<Leader>hb', gitsigns.blame_line, 'Blame current line')
end

local ok_copilot_chat, copilot_chat = pcall(require, 'CopilotChat')

if ok_copilot_chat then
  copilot_chat.setup()
  map({ 'n', 'v' }, '<Leader>cc', '<Cmd>CopilotChatToggle<CR>', 'Toggle Copilot Chat')
end

vim.api.nvim_create_user_command('LazyGit', function()
  if vim.fn.executable('lazygit') ~= 1 then
    vim.notify('lazygit is not installed', vim.log.levels.ERROR)
    return
  end

  vim.cmd('terminal lazygit')
end, {})

map('n', '<Leader>gg', '<Cmd>LazyGit<CR>', 'Open LazyGit')
