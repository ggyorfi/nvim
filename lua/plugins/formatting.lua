return {
  -- Formatting and linting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "black", "isort" },
        lua = { "stylua" },  -- stylua installed via Homebrew (not Mason)
        go = { "gofumpt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  
  -- Linting (ESLint as linter, not LSP)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }
      
      -- Auto-lint on save and text change
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
        callback = function()
          -- Only lint if eslint config exists
          local eslint_config = vim.fn.glob(".eslintrc*", 0, 1)
          if #eslint_config > 0 or vim.fn.filereadable("eslint.config.js") == 1 then
            -- Wrap in pcall to catch parsing errors
            local ok, err = pcall(lint.try_lint)
            if not ok then
              vim.notify("ESLint error: " .. tostring(err), vim.log.levels.WARN)
            end
          end
        end,
      })
    end,
  },
}