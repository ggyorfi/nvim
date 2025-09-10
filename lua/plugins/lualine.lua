return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto", -- Uses your current colorscheme
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true, -- Single statusline for all windows
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { 
            "branch", 
            "diff", 
            "diagnostics",
            {
              function()
                local cwd = vim.fn.getcwd()
                local project_name = vim.fn.fnamemodify(cwd, ":t")
                return "󰉋 " .. project_name
              end,
              color = { fg = "#89b4fa", gui = "bold" }, -- More visible blue color
            }
          },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {}
        },
      })
    end,
  },
}
