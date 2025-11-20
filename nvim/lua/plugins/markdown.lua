return {
  -- Explicitly set the markdown extra to `false` to disable the default.
  { "LazyVim/LazyVim", opts = { extras = { ["lang.markdown"] = false } } },

  -- Configure render-markdown.nvim.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {}, -- Empty options to let LazyVim load it correctly
    config = function()
      require("render-markdown").setup({})
    end,
  },
}
