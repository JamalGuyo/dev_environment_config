return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = {},
      ts_ls = { -- Changed from tsserver to ts_ls
        settings = {
          typescript = {
            inlayHints = { enabled = false },
          },
          javascript = {
            inlayHints = { enabled = false },
          },
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        if client.name == "eslint" then
          client.server_capabilities.documentFormattingProvider = true
        elseif client.name == "ts_ls" then -- Changed from tsserver to ts_ls
          client.server_capabilities.documentFormattingProvider = false
        end
      end,
    })
  end,
}
