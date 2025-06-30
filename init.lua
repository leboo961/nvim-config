-- init.lua
-- This is the main entry point for your Neovim configuration.

-- Set <leader> key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Essential Neovim options for a productive environment
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.opt.tabstop = 4               -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4            -- Size of an indent
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.autoindent = true         -- Copy indent from current line when starting new line
vim.opt.smartindent = true        -- Smarter autoindenting
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Highlight as you type
vim.opt.ignorecase = true         -- Ignore case in search patterns
vim.opt.smartcase = true          -- Smart case search
vim.opt.updatetime = 300          -- Faster completion popup
vim.opt.signcolumn = "yes"        -- Always show the sign column, no jumping
vim.opt.termguicolors = true      -- Enable true colors in the terminal
vim.opt.scrolloff = 8             -- Lines of context around the cursor
vim.opt.sidescrolloff = 8         -- Columns of context around the cursor
vim.opt.undofile = true           -- Persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undo" -- Undo directory
vim.opt.swapfile = false          -- Disable swap files (use persistent undo)
vim.opt.backup = false            -- Disable backup files
vim.opt.writebackup = false       -- Disable write backup files
vim.opt.completeopt = "menu,menuone,noselect" -- Completion menu behavior
vim.opt.mouse = "a"               -- Enable mouse support in all modes
vim.opt.splitright = true         -- Vertical splits open to the right
vim.opt.splitbelow = true         -- Horizontal splits open below
vim.opt.wrap = false              -- Disable line wrapping
vim.opt.conceallevel = 0          -- Disable concealing characters
vim.opt.list = true               -- Show invisible characters
vim.opt.listchars = "tab:» ,nbsp:%,trail:·,eol:¬" -- Define how invisible chars look
vim.opt.cmdheight = 1             -- Command line height
vim.opt.laststatus = 2            -- Always show the statusline
vim.opt.inccommand = "split"      -- Live preview of substitute commands
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.isfname:append("@-@")     -- Allow hyphenated filenames

-- Set up basic autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- Load Lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugin specifications
require("plugins")


