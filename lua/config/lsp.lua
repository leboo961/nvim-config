-- lua/config/lsp.lua
-- This file defines LSP related functions, but the setup of mason-lspconfig
-- and its handlers are now done in lua/plugins.lua.

local M = {}

-- This function defines universal on_attach for LSP servers
M.on_attach = function(client, bufnr)
  -- Enable completion capabilities
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Keybindings for LSP
  local buf_map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- See `:help vim.lsp.*` for documentation on commands
  buf_map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
  buf_map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
  buf_map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
  buf_map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
  buf_map("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "Signature Help" })
  buf_map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add Workspace Folder" })
  buf_map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove Workspace Folder" })
  buf_map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { desc = "List Workspace Folders" })
  buf_map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Type Definition" })
  buf_map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
  buf_map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
  buf_map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
  buf_map("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format Document" })

  -- Diagnostics
  buf_map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
  buf_map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
  buf_map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic list" })
end

-- This function sets up diagnostics and nvim-cmp
function M.setup_diagnostics_and_cmp()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  -- Diagnostics configuration
  vim.diagnostic.config({
    virtual_text = {
      end_col = true, -- Show virtual text at the end of the line
      spacing = 4,
      prefix = "●",
    },
    update_in_insert = false,
    -- Show diagnostics in the sign column and virtual text
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      },
      line_hl_mode = "none", -- Don't highlight the entire line
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticError",
        [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      },
    },
    float = {
      border = "rounded",
      focusable = false,
      header = false,
      -- Source: https://github.com/folke/neodev.nvim/blob/main/lua/neodev/init.lua#L125
      -- Use neodev-like float setup for diagnostics
      source = "always", -- Show source in float
    },
  })

  -- nvim-cmp setup (Autocompletion)
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body) -- For luasnip users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" }, -- Snippets
      { name = "buffer" }, -- Text in current buffer
      { name = "path" }, -- File system paths
    }),
  })

  -- Set up keybinds for luasnip (example)
  vim.keymap.set("i", "<C-k>", function() luasnip.jump(1) end, { silent = true })
  vim.keymap.set("i", "<C-j>", function() luasnip.jump(-1) end, { silent = true })
end

return M

