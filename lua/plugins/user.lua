---@type LazySpec
return {
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    keys = {
      { "<leader>dg", "<cmd>:Neogen<cr>", desc = "Docstring generate" },
    },
    opts = {
      enabled = true,
      languages = {
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
      },
    },
    config = true,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        component_separators = "",
        icons_enabled = true,
        section_separators = { left = "", right = "" },
        theme = "nord",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { { "filename", file_status = true, path = 1 } },
        lualine_c = { { "branch", icon = "" } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      tabline = {
        lualine_a = { "buffers" },
      },
    },
  },

  -- restore floating terminal (Astronvim now uses horizontal by default)
  {
    "akinsho/toggleterm.nvim",
    opts = {
      direction = "float",
    },
  },

  -- linters
  {
    "mfussenegger/nvim-lint",
    ft = { "cpp", "python" },
    config = function()
      require("lint").linters_by_ft = {
        cpp = { "cppcheck" },
        python = { "pylint" },
      }
      local cppcheck = require("lint").linters.cppcheck
      cppcheck.args = {
        "--enable=warning,style,performance,information",
        "--language=c++",
        "--inline-suppr",
        "--cppcheck-build-dir=.cppcheck-build",
        "--template={file}:{line}:{column}: [{id}] {severity}: {message}",
      }

      vim.api.nvim_create_autocmd({ "BufWritePre", "InsertLeave" }, {
        pattern = "",
        callback = function(opts)
          -- ensure the cppcheck build dir exists
          if vim.bo[opts.buf].filetype == "cpp" then
            local Path = require "plenary.path"
            local expected_build_dir = Path:new(vim.loop.cwd(), ".cppcheck-build")
            if not expected_build_dir:exists() then
              print "creating .cppcheck-build directory"
              expected_build_dir:mkdir()
            end
          end

          local lint_status, lint = pcall(require, "lint")
          if lint_status then lint.try_lint() end
        end,
      })
    end,
  },

  -- scala
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()

      -- Example of settings
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        useGlobalExecutable = true,
      }

      -- *READ THIS*
      -- I *highly* recommend setting statusBarProvider to true, however if you do,
      -- you *have* to have a setting to display this in your statusline or else
      -- you'll not see any messages from metals. There is more info in the help
      -- docs about this
      -- metals_config.init_options.statusBarProvider = "on"

      -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

      metals_config.on_attach = function(client, bufnr)
        require("metals").setup_dap()

        -- LSP mappings
        map("n", "gD", vim.lsp.buf.definition)
        map("n", "K", vim.lsp.buf.hover)
        map("n", "gi", vim.lsp.buf.implementation)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "gds", vim.lsp.buf.document_symbol)
        map("n", "gws", vim.lsp.buf.workspace_symbol)
        map("n", "<leader>cl", vim.lsp.codelens.run)
        map("n", "<leader>sh", vim.lsp.buf.signature_help)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>f", vim.lsp.buf.format)
        map("n", "<leader>ca", vim.lsp.buf.code_action)

        map("n", "<leader>ws", function() require("metals").hover_worksheet() end)

        -- all workspace diagnostics
        map("n", "<leader>aa", vim.diagnostic.setqflist)

        -- all workspace errors
        map("n", "<leader>ae", function() vim.diagnostic.setqflist { severity = "E" } end)

        -- all workspace warnings
        map("n", "<leader>aw", function() vim.diagnostic.setqflist { severity = "W" } end)

        -- buffer diagnostics only
        map("n", "<leader>d", vim.diagnostic.setloclist)

        map("n", "[c", function() vim.diagnostic.goto_prev { wrap = false } end)

        map("n", "]c", function() vim.diagnostic.goto_next { wrap = false } end)

        -- Example mappings for usage with nvim-dap. If you don't use that, you can
        -- skip these
        map("n", "<leader>dc", function() require("dap").continue() end)

        map("n", "<leader>dr", function() require("dap").repl.toggle() end)

        map("n", "<leader>dK", function() require("dap.ui.widgets").hover() end)

        map("n", "<leader>dt", function() require("dap").toggle_breakpoint() end)

        map("n", "<leader>dso", function() require("dap").step_over() end)

        map("n", "<leader>dsi", function() require("dap").step_into() end)

        map("n", "<leader>dl", function() require("dap").run_last() end)
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function() require("metals").initialize_or_attach(metals_config) end,
        group = nvim_metals_group,
      })
    end,
  },

  -- {
  --   "nvim-lualine/lualine.nvim",
  --   dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
  --   event = "VeryLazy",
  --   config = function()
  --     require("lualine").setup {
  --       theme = "ayu-light",
  --       winbar = {},
  --       sections = {
  --         lualine_a = { "mode" },
  --         lualine_b = { "branch", "diff", "diagnostics" },
  --         lualine_c = { "filename" },
  --         lualine_x = { "encoding", "fileformat", "filetype" },
  --         lualine_y = { "progress" },
  --         lualine_z = { "location" },
  --       },
  --     }
  --   end,
  -- },

  -- == Examples of Adding Plugins ==

  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },
  --
  -- -- == Examples of Overriding Plugins ==
  --
  -- -- customize alpha options
  -- {
  --   "goolord/alpha-nvim",
  --   opts = function(_, opts)
  --     -- customize the dashboard header
  --     opts.section.header.val = {
  --       " █████  ███████ ████████ ██████   ██████",
  --       "██   ██ ██         ██    ██   ██ ██    ██",
  --       "███████ ███████    ██    ██████  ██    ██",
  --       "██   ██      ██    ██    ██   ██ ██    ██",
  --       "██   ██ ███████    ██    ██   ██  ██████",
  --       " ",
  --       "    ███    ██ ██    ██ ██ ███    ███",
  --       "    ████   ██ ██    ██ ██ ████  ████",
  --       "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
  --       "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
  --       "    ██   ████   ████   ██ ██      ██",
  --     }
  --     return opts
  --   end,
  -- },
  --
  -- -- You can disable default plugins as follows:
  -- { "max397574/better-escape.nvim", enabled = false },
  --
  -- -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  -- {
  --   "L3MON4D3/LuaSnip",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom luasnip configuration such as filetype extend or custom snippets
  --     local luasnip = require "luasnip"
  --     luasnip.filetype_extend("javascript", { "javascriptreact" })
  --   end,
  -- },
  --
  -- {
  --   "windwp/nvim-autopairs",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom autopairs configuration such as custom rules
  --     local npairs = require "nvim-autopairs"
  --     local Rule = require "nvim-autopairs.rule"
  --     local cond = require "nvim-autopairs.conds"
  --     npairs.add_rules(
  --       {
  --         Rule("$", "$", { "tex", "latex" })
  --           -- don't add a pair if the next character is %
  --           :with_pair(cond.not_after_regex "%%")
  --           -- don't add a pair if  the previous character is xxx
  --           :with_pair(
  --             cond.not_before_regex("xxx", 3)
  --           )
  --           -- don't move right when repeat character
  --           :with_move(cond.none())
  --           -- don't delete if the next character is xx
  --           :with_del(cond.not_after_regex "xx")
  --           -- disable adding a newline when you press <cr>
  --           :with_cr(cond.none()),
  --       },
  --       -- disable for .vim files, but it work for another filetypes
  --       Rule("a", "a", "-vim")
  --     )
  --   end,
  -- },
}
