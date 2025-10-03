return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "markdown",
          "bash",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "html",
          "css",
          "toml",
        },
      })
    end,
  },
}