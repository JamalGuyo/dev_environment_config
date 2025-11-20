-- Provides functionality like a file explorer, search and replace, fuzzy finding, git integration.
--
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  },

  -- git diff
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff (Diffview)" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Git Diffview" },
    },
  },
  -- git blame
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- Enable Git blame inline annotations
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' places the blame text at the end of the line
        delay = 500, -- Delay in milliseconds before blame shows
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    },
  },
  -- incremental rename
  {
    "smjonas/inc-rename.nvim",
    opts = {},
  },
  -- relativenumber for neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.cmd([[
              setlocal relativenumber
            ]])
          end,
        },
      },
    },
  },
  -- filename
  {
    "b0o/incline.nvim",
    main = "incline",
    event = "VeryLazy",
    keys = {
      {
        "<leader>uN",
        function()
          require("incline").toggle()
        end,
        desc = "Incline Toggle",
      },
    },
    opts = function()
      local separator = { left = "", right = "" } -- vim.g.separators.component
      return {
        ---@param props { buf: number, win: number, focused: boolean }
        ---@return render_result[]
        render = function(props)
          local theme = require("lualine.themes." .. vim.g.colors_name)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local group = props.focused and "Normal" or "Inactive"
          local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf })
          for hl_group, value in pairs({
            InclineBorderNormal = { fg = theme.normal.b.bg, bg = "NONE" },
            InclineBorderInactive = { fg = theme.inactive.b.bg, bg = "NONE" },
            InclineTextNormal = { fg = theme.normal.b.fg, bg = theme.normal.b.bg },
            InclineTextInactive = { bg = theme.inactive.b.bg, fg = theme.normal.b.fg },
          }) do
            vim.api.nvim_set_hl(0, hl_group, value)
          end
          local function get_git_diff()
            local signs, diff = vim.b[props.buf].gitsigns_status_dict or {}, {}
            local icons = {
              added = LazyVim.config.icons.git.added,
              changed = LazyVim.config.icons.git.modified,
              removed = LazyVim.config.icons.git.removed,
            }
            for key, icon in pairs(icons) do
              if signs[key] and signs[key] ~= 0 then
                table.insert(diff, { icon .. signs[key] .. " ", group = "Diff" .. key })
              end
            end
            if #diff > 0 then
              table.insert(diff, 1, " ")
            end
            return diff
          end
          local function get_diagnostic_label()
            local diagnostics = {}
            for severity, icon in pairs(LazyVim.config.icons.diagnostics) do
              local n = #vim.diagnostic.get(props.buf, {
                severity = vim.diagnostic.severity[string.upper(severity)],
              })
              if n > 0 then
                table.insert(diagnostics, {
                  icon .. n .. " ",
                  group = "DiagnosticSign" .. severity,
                })
              end
            end
            if #diagnostics > 0 then
              table.insert(diagnostics, 1, " ")
            end
            return diagnostics
          end
          local function expand(render_result)
            local index = 1
            while index < #render_result do
              local value = render_result[index]
              if #value > 0 then
                table.insert(render_result, index + 1, separator.right)
                index = index + 1
              end
              index = index + 1
            end
            return render_result
          end
          return #filename > 0
              and {
                {
                  "", -- vim.g.separators.section.right
                  group = "InclineBorder" .. group,
                },
                expand({
                  get_diagnostic_label(),
                  get_git_diff(),
                  {
                    ft_icon and { " ", ft_icon, guifg = ft_color } or "",
                    " ",
                    {
                      filename,
                      gui = modified and "bold" or nil,
                    },
                    " ",
                    modified and "● " or "",
                  },
                  group = "InclineText" .. group,
                }),
              }
            or {}
        end,
        highlight = {
          groups = {
            InclineNormal = { default = false, guifg = "NONE", guibg = "NONE" },
            InclineNormalNC = { default = false, guifg = "NONE", guibg = "NONE" },
          },
        },
        window = {
          padding = 0,
          margin = { vertical = 0, horizontal = 0 },
          placement = { vertical = "top", horizontal = "right" },
        },
      }
    end,
  },
  -- lua line
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_b = { "branch" }, -- Only show branch, remove diff & diagnostics
        lualine_c = { { "filename", path = 1 }, "fileformat", "filetype" }, -- Show only the filename
        lualine_x = {}, -- Remove encoding, fileformat, and filetype
      },
    },
  },

  -- neotree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "float",
        popup = {
          size = {
            height = "80%", -- Adjust height percentage
            width = "60%", -- Adjust width percentage
          },
          border = "rounded", -- Rounded corners like Telescope
        },
      },
    },
  },

  -- fzf-lua
  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        height = 0.85, -- fzf window height
        preview = {
          hidden = "nohidden", -- Show hidden files
        },
      },
      fzf_opts = {
        ["--border"] = "sharp", -- Sharp borders
        ["--preview-window"] = "right:50%", -- Show preview on the right
      },
    },
    config = function()
      local fzf = require("fzf-lua")

      -- fzf-lua search for files (with the path of the current buffer)
      vim.keymap.set("n", "<leader>sf", function()
        -- Ensure current directory is passed to fzf-lua
        local current_path = vim.fn.expand("%:p:h")
        fzf.files({
          cwd = current_path, -- Use the current directory of the open file
          actions = {
            ["ctrl-u"] = "cd ..", -- Go up a folder using Ctrl+U
          },
        })
      end, { desc = "Search files in current buffer directory with fzf-lua" })
    end,
  },
  -- treesitter context
  {
    "nvim-treesitter/nvim-treesitter-context",
  },
}
