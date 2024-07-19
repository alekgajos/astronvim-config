return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "nvim-neotest/nvim-nio",
      },
      keys = {
        { "<leader>du", function() require("dapui").toggle {} end, desc = "Dap UI" },
        { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" } },
      },
      opts = {
        -- layouts = {
        --   {
        --     elements = {
        --       "watches",
        --     },
        --     size = 0.2,
        --     position = "left",
        --   },
        -- },
        -- controls = {
        --   enabled = false,
        -- },
        -- render = {
        --   max_value_lines = 3,
        -- },
        -- floating = {
        --   max_height = nil, -- These can be integers or a float between 0 and 1.
        --   max_width = nil, -- Floats will be treated as percentage of your screen.
        --   border = "single", -- Border style. Can be "single", "double" or "rounded"
        --   mappings = {
        --     close = { "q", "<Esc>" },
        --   },
        -- },
      },
    },
  },

  -- key mappings
  keys = {
    {
      "<leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
      desc = "Breakpoint Condition",
    },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    {
      "<leader>dc",
      function()
        if vim.fn.filereadable(vim.fn.getcwd() .. "/.vscode/launch.json") then
          require("dap.ext.vscode").load_launchjs(nil, { lldb = { "c", "cpp" }, cppdbg = { "c", "cpp" } })
          -- require('dap.ext.vscode').load_launchjs(nil, { cppdbg = {'c', 'cpp'} })
        end
        require("dap").continue()
      end,
      desc = "Continue",
    },
    { "<leader>da", function() require("dap").continue { before = get_args } end, desc = "Run with Args" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    {
      "<leader>d?",
      function()
        local widgets = require "dap.ui.widgets"
        widgets.centered_float(widgets.scopes)
      end,
      desc = "Scopes",
    },
  },

  -- setup
  config = function()
    local dap = require "dap"

    local dap_virtual_text_status = require "nvim-dap-virtual-text"

    local dapui = require "dapui"

    dap_virtual_text_status.setup {
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
      show_stop_reason = true, -- show stop reason when stopped for exceptions
      commented = true, -- prefix virtual text with comment string
      only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
      all_references = false, -- show virtual text on all all references of the variable (not only definitions)
      filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
      -- experimental features:
      virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
      all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
      virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
      virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
      -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    }

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- setup for lldb-vscode
    dap.adapters.lldb = {
      type = "executable",
      command = "lldb-vscode-16",
      name = "lldb",
    }

    dap.adapters.cppdbg = {
      id = "cppdbg",
      name = "cppdbg",
      type = "executable",
      command = "/root/extension/debugAdapters/bin/OpenDebugAD7",
    }

    -- these will be merged with configurations defined in $CWD/.vscode/launch.json
    -- on launching with dap.continue, these can be chosen interactively

    -- commented out for now to only use per-project configurations
    -- dap.configurations.cpp = {
    --   {
    --     name = "Launch LLDB",
    --     type = "lldb",
    --     request = "launch",
    --     program = function()
    --       return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    --     end,
    --     cwd = "${workspaceFolder}",
    --     stopOnEntry = false,
    --     args = {},
    --   },
    --   {
    --     name = "Launch GDB",
    --     type = "cppdbg",
    --     request = "launch",
    --     program = function()
    --       return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    --     end,
    --     cwd = "${workspaceFolder}",
    --     stopOnEntry = false,
    --     args = {},
    --   }
    --
    -- }

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
  end,
}
