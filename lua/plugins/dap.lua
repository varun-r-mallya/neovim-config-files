-- Docs at https://github.com/mfussenegger/nvim-dap-python are useful.
return {
  -- keep-sorted start block=yes

  {
    "mfussenegger/nvim-dap",
    lazy = true,
    -- Copied from LazyVim/lua/lazyvim/plugins/extras/dap/core.lua and
    -- modified.
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle Breakpoint"
      },

      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "Continue"
      },

      {
        "<leader>dC",
        function() require("dap").run_to_cursor() end,
        desc = "Run to Cursor"
      },

      {
        "<leader>dT",
        function() require("dap").terminate() end,
        desc = "Terminate"
      },

      {
        "<F10>",
        function() require("dap").step_over() end,
        desc = "Step Over"
      },

      {
        "<F11>",
        function() require("dap").step_into() end,
        desc = "Step Into"
      },

      {
        "<S-F11>",
        function() require("dap").step_out() end,
        desc = "Step Out"
      },
      -- Consider the mappings at
      -- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#mappings
      {
        "<leader>dt",
        function()
          if vim.bo[0].filetype == "go" then
            require("dap-go").debug_test()
          elseif vim.bo[0].filetype == "python" then
            require("dap-python").test_method()
          else
            vim.print("No test support for " .. vim.bo[0].filetype)
          end
        end,
        desc = "Debug the test method above the cursor"
      },
    },
    -- GDB >= 14 has a native DAP server (`gdb -i dap`), so no extra plugin
    -- is needed for C/C++/Rust debugging.
    config = function()
      local dap = require("dap")

      -- Remembers the last executable path picked, across configs, so
      -- re-launching the same target is just <Enter> instead of retyping it.
      local last_program = vim.fn.getcwd() .. "/"
      local function pick_program()
        last_program = vim.fn.input("Path to executable: ", last_program, "file")
        return last_program
      end

      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "-i", "dap" },
      }

      local gdb_configs = {
        {
          name = "Run with GDB",
          type = "gdb",
          request = "launch",
          program = pick_program,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to process",
          type = "gdb",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      for _, lang in ipairs({ "c", "cpp", "rust" }) do
        dap.configurations[lang] = vim.list_extend(dap.configurations[lang] or {}, gdb_configs)
        -- Also reuse the cached path for the codelldb "Launch file" config
        -- from the clangd extra, so it doesn't prompt from scratch too.
        for _, cfg in ipairs(dap.configurations[lang]) do
          if cfg.name == "Launch file" then
            cfg.program = pick_program
          end
        end
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    config = true,
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Dap UI"
      },
    },
    dependencies = {
      -- keep-sorted start block=yes
      {
        "jay-babu/mason-nvim-dap.nvim",
        ---@type MasonNvimDapSettings
        opts = {
          -- This line is essential to making automatic installation work
          -- :exploding-brain
          handlers = {},
          automatic_installation = false,
          -- DAP servers: these will be installed by mason-tool-installer.nvim
          -- for consistency.
          ensure_installed = {},
        },
        dependencies = {
          "mfussenegger/nvim-dap",
          "mason-org/mason.nvim",
        },
      },
      {
        "leoluz/nvim-dap-go",
        config = true,
        dependencies = {
          "mfussenegger/nvim-dap",
        },
      },
      {
        "mfussenegger/nvim-dap-python",
        lazy = true,
        config = function()
          -- debugpy is installed in my standard Python virtualenv so that it's
          -- available with all the other modules.
          require("dap-python").setup("python3")
        end,
        dependencies = {
          "mfussenegger/nvim-dap",
        },
      },
      {
        "nvim-neotest/nvim-nio",
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        config = true,
        dependencies = {
          "mfussenegger/nvim-dap",
        },
      },
      -- keep-sorted end
    },
  },
  -- keep-sorted end
}
