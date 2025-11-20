-- Set up formatters using conform.nvim.
--
return {
  -- support html formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        ["angular"] = { "prettier" },
        python = { "black" },
      },
      formatters = {
        black = {
          command = "black",
          args = { "-" },
          stdin = true,
        },
      },
    },
  },
}
