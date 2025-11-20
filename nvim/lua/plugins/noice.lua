return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- Your existing noice options (if any)
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    -- Add this init function to enable macro recording alerts
    init = function()
      -- Show notification when macro recording starts
      vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function()
          local reg = vim.fn.reg_recording()
          require("noice").notify("Recording macro @" .. reg, "info", { title = "Macro Recording" })
        end,
      })

      -- Show notification when macro recording stops
      vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
          require("noice").notify("Stopped recording", "info", { title = "Macro Recording" })
          -- Small delay to ensure the message is seen
          vim.defer_fn(function()
            require("noice").notify("", "info", { title = "", skip_history = true })
          end, 1000)
        end,
      })
    end,
  },
}
