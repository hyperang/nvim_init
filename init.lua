local opt = vim.opt
local cmd = vim.cmd

-- Set plugins --
-- require("plugins.plugins")
-- require("plugins.lualine")
-- require("plugins.nvim-tree")
-- require("plugins.treesitter")
-- require("plugins.cmp")
-- require("plugins.autopairs")
-- require("plugins.lsp")
-- require("plugins.comment")
-- require("plugins.bufferline")
-- require("plugins.gitsigns")
-- require("plugins.telescope")

-- Set line numbers --
opt.relativenumber = true
opt.number = true

-- Set identation --
opt.tabstop = 2
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- Set wrap --
opt.wrap = false

-- Set cursor --
opt.cursorline = true

-- Set mouse --
opt.mouse:append("a")

-- Set clipboard --
opt.clipboard:append("unnamedplus")

-- Set split --
opt.splitright = true
opt.splitbelow = true

-- Set search --
opt.ignorecase = true
opt.smartcase = true

-- Set exterior --
opt.termguicolors = true
opt.signcolumn = "yes"
vim.cmd[[colorscheme tokyonight]]

-- Set keymaps --
vim.g.mapleader = " " 
local keymap = vim.keymap
-- VISUAL -- 
-- keymap.set("v", "J", ":m '>+1<CR>gv=gv") 
-- keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- NORMAL --
-- split window
keymap.set("n", "<leader>s", "<C-w>v")
keymap.set("n", "<leader>sh", "<C-w>s")
-- close window
keymap.set("n", "<leader>c", "<C-w>c")
-- switch window
keymap.set("n", "<leader>j", "<C-w>h")
keymap.set("n", "<leader>l", "<C-w>l")
keymap.set("n", "<leader>i", "<C-w>k")
keymap.set("n", "<leader>k", "<C-w>j")
-- no highlight
keymap.set("n", "<leader>h", ":nohl<CR>")
-- clipboard paste
-- keymap.set("n", "<leader>p", "+p")
-- nvim-tree
keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>")
-- change buffer page
keymap.set("n", "<leader>q", ":bprevious<CR>")
keymap.set("n", "<leader>e", ":bnext<CR>")


-- AutoPairs dependecy -- 
local npairs_ok, npairs = pcall(require, "nvim-autopairs")
if not npairs_ok then
  return
end

npairs.setup {
  check_ts = true,
  ts_config = {
    lua = { "string", "source" },
    javascript = { "string", "template_string" },
  },
  fast_wrap = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'Search',
    highlight_grey='Comment'
  },
}

-- auto-pairs work when editing comment --

local cmp_autopairs = require "nvim-autopairs.completion.cmp"
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })

-- bufferline dependecy --
opt.termguicolors = true

require("bufferline").setup {
    options = {
        -- use nvim_lsp
        diagnostics = "nvim_lsp",
        -- make position for nvim-tree
        offsets = {{
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left"
        }}
    }
}

-- cmp dependecy --
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip.loaders.from_vscode").lazy_load()


local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end


cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(),  -- cancel completion，esc work too
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  }),


  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  })
})

-- Comment dependecy --
require('Comment').setup()

-- Gitsigns dependecy --
require('gitsigns').setup {
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        hangedelete = { text = '~' }
    }
}

-- Lsp dependecy --
require("mason").setup({
  ui = {
      icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
      }
  }
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
  },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").lua_ls.setup {
  capabilities = capabilities,
}

-- Lualine dependency --
require('lualine').setup ({
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
})

-- Nvim-tree dependecy --
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPulgin = 1

require("nvim-tree").setup()

-- Telescope dependecy --
-- vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})  -- need to install ripgrep in environment
-- vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Treesitter dependecy --
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "bash", "cpp", "javascript", "typescript", "json", "java", "python" },
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
    additional_vim_regex_highlighting = false,
  },

  rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = nil,
  }
}



-- Packer Bootstrap --
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Automatically install plugins when saving this file
cmd([[
    augroup packer_user_config
    	autocmd!
	    autocmd BufWritePost plugins.lua source <afile> | PackerSync
    augroup end
]])

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here
  -- use 'foo1/bar1.nvim'
  -- use 'foo2/bar2.nvim'
  use 'folke/tokyonight.nvim' -- topic
  use {
      'nvim-lualine/lualine.nvim', -- status bar
      requires = { 'nvim-tree/nvim-web-devicons', opt = true } -- status bar icon
  }
  use {
      'nvim-tree/nvim-tree.lua', -- document tree
      requires = {
          'nvim-tree/nvim-web-devicons', -- optional document tree icon
      }
      -- config = function()
      --     require("nvim-tree").setup {}
      -- end
  }
  use 'christoomey/vim-tmux-navigator' -- switch document tree and codeview 
  use 'nvim-treesitter/nvim-treesitter' -- synx highlight
  use 'p00f/nvim-ts-rainbow' -- synx highlight
  use {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig'
  }

  -- code auto-completion --
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip' -- snippets engine
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'
  use 'hrsh7th/cmp-path' -- file path

  use 'numToStr/Comment.nvim' -- gcc & gc comment
  use 'windwp/nvim-autopairs' -- auto brackets completion

  use 'akinsho/bufferline.nvim' -- buffer head-cutline
  use 'lewis6991/gitsigns.nvim' -- git comment

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',  -- file retrieval
    requires = { {'nvim-lua/plenary.nvim'} }
  }


-- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
