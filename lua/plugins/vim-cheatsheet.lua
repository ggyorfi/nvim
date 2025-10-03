return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/cheatsheet",
    name = "vim-cheatsheet",
    keys = {
      {
        "<leader>h",
        function()
          require("cheatsheet").toggle()
        end,
        desc = "Vim Cheatsheet",
      },
    },
  },
}
