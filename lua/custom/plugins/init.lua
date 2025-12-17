-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  --kitty-like scrolls and smooth C-u and C-d
  -- {
  --   'karb94/neoscroll.nvim',
  --   opts = {
  --     duration_multiplier = 0.35, -- make it fast
  --     -- Enable this if you have a beefy PC. It's to work with nvim-scrollbar,
  --     -- sacrificing performance
  --     -- ignored_events = {},
  --
  --     -- By hiding the scrollbar we don't sacrifice performance
  --     pre_hook = function()
  --       local scrollbar_util = require 'scrollbar.utils'
  --       scrollbar_util.hide()
  --     end,
  --     post_hook = function()
  --       local scrollbar_util = require 'scrollbar.utils'
  --       scrollbar_util.show()
  --     end,
  --   },
  -- },
  -- {
  --   'sphamba/smear-cursor.nvim',
  --   opts = {
  --     -- carbonfox. Maybe get it from terminal config?
  --     cursor_color = '#b6b8bb',
  --     -- Smear cursor when switching buffers or windows.
  --     smear_between_buffers = true,
  --
  --     -- Smear cursor when moving within line or to neighbor lines.
  --     smear_between_neighbor_lines = true,
  --
  --     -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
  --     -- Smears will blend better on all backgrounds.
  --     -- legacy_computing_symbols_support = true,
  --
  --     -- quick opts
  --     stiffness = 0.8, -- 0.6      [0, 1]
  --     trailing_stiffness = 0.5, -- 0.3      [0, 1]
  --     distance_stop_animating = 0.5, -- 0.1      > 0
  --     hide_target_hack = false, -- true     boolean
  --
  --     -- FIRE OPTS
  --     -- stiffness = 0.3,
  --     -- trailing_stiffness = 0.1,
  --     -- trailing_exponent = 3,
  --     -- gamma = 1,
  --     -- volume_reduction_exponent = -0.1,
  --   },
  -- },

  --diffview
  {
    'sindrets/diffview.nvim',
    -- cmd = 'DiffviewOpen',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      disable_diagnostics = true,
      trail = false,
    },
  },

  {
    'rbong/vim-flog',
    lazy = true,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = {
      'tpope/vim-fugitive',
    },
  },

  {
    -- neogit
    'NeoGitOrg/neogit',
    -- old commit
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'sindrets/diffview.nvim',
    },
    config = function()
      local neogit = require 'neogit'
      neogit.setup {
        telescope_sorter = function()
          return require('telescope').extensions.fzf.native_fzf_sorter()
        end,
        integrations = {
          telescope = true,
          diffview = true,
        },
        -- Maybe get this depending on terminal type?
        graph_style = 'kitty',
        popup = {
          kind = 'floating',
        },
      }
      vim.api.nvim_create_user_command('NeogitListFilesTree', function()
        local neogit_files = require 'neogit.lib.git.files'
        local files = neogit_files.all_tree { with_dir = true }
        print(vim.inspect(files))
      end, { nargs = 0 })
    end,
  },

  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'Lazy[G]it' },
      { '<leader>lc', '<cmd>LazyGitCurrentFile<cr>', desc = 'LazyGit[C]urrentFile' },
    },
  },

  -- save previous session
  {
    'rmagatti/auto-session',
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {},
    config = function()
      -- vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions" is recommended
      -- Note that we omit folds, it kinda conflicts with nvim-ufo
      vim.o.sessionoptions = 'blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions'

      require('auto-session').setup {
        suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      }
    end,
  },

  -- FOLDING!!! NEEDED!!! Start.
  {
    'kevinhwang91/nvim-ufo',
    -- commit = 'v1.4.0', -- get stable, nightly conflicts with neogit
    dependencies = {
      'kevinhwang91/promise-async',
    },
    config = function()
      -- FOLDING options
      -- FOLDING
      vim.o.foldcolumn = '0' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Using ufo provider need remap `zR` and `zM`. If Neovim is -1.6.1, remap yourself
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      -- Option 2: nvim lsp as LSP client
      -- Tell the server the capability of foldingRange,
      -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local language_servers = require('lspconfig').util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
      for _, ls in ipairs(language_servers) do
        require('lspconfig')[ls].setup {
          capabilities = capabilities,
          -- you can add other fields for setting up lsp server in this table
        }
      end
      require('ufo').setup()
    end,
  },

  -- SCROLLBAR, it's essential for error navigation
  {
    'petertriho/nvim-scrollbar',
    dependencies = { 'kevinhwang91/nvim-hlslens' },
    config = function()
      require('scrollbar').setup {
        handle = {},
        marks = {
          GitChange = { color = 0xFF0000 },
        },
      }
      require('scrollbar.handlers.gitsigns').setup() -- hunks
      require('scrollbar.handlers.search').setup {
        -- hlslens config overrides
      }
    end,
  },

  -- {
  --   'github/copilot.vim',
  -- },
  -- {
  --   'CopilotC-Nvim/CopilotChat.nvim',
  --   dependencies = {
  --     { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
  --     { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
  --   },
  --   build = 'make tiktoken', -- Only on MacOS or Linux
  --   opts = {
  --     -- See Configuration section for options
  --   },
  --   -- See Commands section for default commands if you want to lazy load on them
  -- },
  -- for tmux
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
}
