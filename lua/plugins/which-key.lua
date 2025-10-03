return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      delay = 200,
      defaults = {},
      win = {
        title = false,
      },
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>b", group = "buffer" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>w", group = "windows" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "ga", group = "text-case" }, -- Add group for our text-case plugin
          { "z", group = "fold" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add(opts.spec)
    end,
  },
}