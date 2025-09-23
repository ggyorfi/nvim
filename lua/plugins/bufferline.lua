return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
  local bufferline = require("bufferline")

  -- Define custom highlight group for pin icon
  vim.api.nvim_set_hl(0, "BufferLinePinIcon", { fg = "#f38ba8" })

    bufferline.setup({
      options = {
        style_preset = bufferline.style_preset.no_italic,
        numbers = function(opts) return opts.ordinal end,
        separator_style = "slant",
        always_show_bufferline = true,
        diagnostics = "nvim_lsp",
        custom_filter = function(bufnr) return vim.bo[bufnr].buftype ~= "terminal" end,
          offsets = {
            {
              filetype = "snacks_layout_box",
              text = " File Explorer",
              highlight = "BufferLineFill", -- Uses black background to match
              text_align = "left",
            }
          },
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        -- Custom icons
        indicator = {
          style = "icon",
        },
        -- Pin configuration
        groups = {
          items = {
            require('bufferline.groups').builtin.pinned:with({
              icon = "%#BufferLinePinIcon#󰐃%*",
            })
          }
        },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        left_trunc_marker = "󰁍",
        right_trunc_marker = "󰁔",
      },
      highlights = {
        fill = {
          bg = "#000000", -- Full black background behind tabs
        },
        tab_separator = {
          fg = "#000000", -- Black visual background for corners (inverted)
        },
        tab_separator_selected = {
          fg = "#000000", -- Black visual background for selected corners (inverted)
        },
        separator = {
          fg = "#000000", -- Black visual background for separators (inverted)
        },
        separator_selected = {
          fg = "#000000", -- Black visual background for selected separators (inverted)
        },
        offset_separator = {
          bg = "#000000", -- Black background for File Explorer offset
        },
        -- Inactive window separator states (when focus is on explorer)
        separator_visible = {
          fg = "#000000", -- Black visual background for visible separators when inactive
          bg = { attribute = "bg", highlight = "Normal" }, -- Use Normal bg color for corners
        },
        -- Active tab when window is not focused (make it same as focused)
        buffer_visible = {
          bg = { attribute = "bg", highlight = "Normal" }, -- Use Normal bg color
          fg = { attribute = "fg", highlight = "Normal" }, -- Use Normal fg color
        },
      },
    })
    end,
  },
}
