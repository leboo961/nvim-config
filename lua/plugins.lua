local lazy_plugins = {
  -- Plugin Manager
  {
    "folke/lazy.nvim",
    version = "*",
    lazy = false,
    config = function()
      -- Configure lazy.nvim, if needed (defaults are usually fine)
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Autocompletion and Snippets
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip", -- Snippet engine
    },
    config = function()
      local lspconfig = require("lspconfig")
      local lsp_config_module = require("config.lsp") -- Ensure config.lsp is loaded
      local on_attach = lsp_config_module.on_attach -- Get the on_attach function from lsp.lua

      -- Capabilities for LSP clients
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Configure individual LSP servers
      -- Each server is set up with the universal on_attach function and capabilities.
      -- Add any server-specific settings here.

      -- C/C++ LSP: clangd
      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--header-insertion=never", -- Prevent automatic header insertion, useful for large projects
          "--background-index", -- Enable background indexing
          "--clang-tidy", -- Enable clang-tidy checks
          "--pch-storage=disk", -- Store PCH on disk to speed up subsequent compilations
          "-j=8", -- Number of threads for clangd
          -- Add compiler flags or compile_commands.json path if needed for specific projects
        },
      })

      -- Python LSP: pyright
      lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          pyright = {
            disableOrganizeImports = true, -- Disable automatic organize imports on save (can be slow)
            analysis = {
              autoSearchPaths = true,
              use="basic",
              diagnosticMode = "workspace",
              typeCheckingMode = "off", -- 'off', 'basic', 'strict'
              -- Add ignore files/folders to speed up large projects
              ignore = {
                "**/.venv/**",
                "**/node_modules/**",
                "**/.git/**",
                "**/__pycache__/**",
              },
            },
          },
        },
      })

      -- Fortran LSP: fortls
      lspconfig.fortls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- CMake LSP: cmake_language_server
      lspconfig.cmake_language_server.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Go LSP: gopls
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            rangeVariableTypes = true,
          },
        },
      })

      -- Rust LSP: rust_analyzer
      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            procMacro = {
                enable = true,
            },
            check = {
              command = "clippy", -- Use clippy for checks
              extraArgs = { "--workspace" },
            },
            cargo = {
              allFeatures = true,
            },
          },
        },
      })

      -- Bash LSP: bashls
      lspconfig.bashls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Lua LSP: lua_ls
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false, -- Don't check external libraries for performance
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
              },
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Vimscript LSP: vimls
      lspconfig.vimls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Initial setup for LSP diagnostics and nvim-cmp (remains in config.lsp)
      lsp_config_module.setup_diagnostics_and_cmp()
    end,
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope", -- Lazy load Telescope
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.git/", "%.cache/", "%.DS_Store", "node_modules" },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
          },
          sorting_strategy = "ascending",
          selection_strategy = "respect_multi",
          -- Previewers are heavy, keep them minimal or lazy-load them if possible
          -- For basic use, default previewers are fine.
        },
        extensions = {
          -- Can add extensions here if needed, but keep it minimal
        },
      })

      -- Load extensions if you add them
      -- telescope.load_extension("fzf") -- Example if you use fzf native

      -- Keymaps for Telescope
      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
      map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
    end,
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "python", "fortran", "cmake", "go", "rust", "bash", "lua", "vim",
          "json", "yaml", "markdown", "markdown_inline", "html", "css", "javascript",
        }, -- Install common parsers
        sync_install = false, -- Install parsers asynchronously
        auto_install = true,
        highlight = {
          enable = true, -- Enable syntax highlighting
        },
        indent = { enable = true }, -- Enable auto-indentation
      })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "✖" },
          topdelete = { text = "━" },
          changedelete = { text = "═" },
          untracked = { text = "┆" },
        },
        current_line_blame = true, -- Display blame info on current line
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 100,
          ignore_whitespace = false,
        },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local map = vim.keymap.set

          -- Navigation
          map("n", "]h", function()
            if vim.wo.diff then
              return "]h"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Next Hunk" })

          map("n", "[h", function()
            if vim.wo.diff then
              return "[h"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Prev Hunk" })

          -- Actions
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
          map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end, { desc = "Blame Line" })
          map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end, { desc = "Diff This (Staged)" })
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
        end,
      })
    end,
  },

  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    priority = 1000, -- Ensure it loads first
    config = function()
             -- Default options:
            require("gruvbox").setup({
                terminal_colors = true, -- add neovim terminal colors
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                inverse = true, -- invert background for search, diffs, statuslines and errors
                contrast = "", -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = false,
            })
            vim.cmd.colorscheme("gruvbox")
    end,
  },
}

-- Setup Lazy.nvim with your plugins
require("lazy").setup(lazy_plugins, {
  install = { colorscheme = { "gruvbox" } }, -- Install colorscheme immediately
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "gzip",
        "zipPlugin",
        "tarPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "matchit",
        "tutor",
        "rplugin",
        "syntax",
        "logipat",
        "rrhelper",
        "tohtml",
        "spellfile",
        "tagfiles",
        "ftplugin",
      },
    },
  },
})
