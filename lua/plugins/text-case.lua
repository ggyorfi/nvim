return {
  {
    "johmsalas/text-case.nvim",
    -- No dependencies needed for basic text conversion
    config = function()
      require("textcase").setup({
        -- Enable all default keymappings
        default_keymappings_enabled = true,
        prefix = "ga",
        -- Enable all conversion methods
        enabled_methods = {
          "to_upper_case",      -- gau: UPPER CASE
          "to_lower_case",      -- gal: lower case  
          "to_snake_case",      -- gas: snake_case
          "to_dash_case",       -- gad: dash-case
          "to_title_dash_case", -- ga?: Title-Case
          "to_constant_case",   -- gan: CONSTANT_CASE
          "to_dot_case",        -- ga?: dot.case
          "to_comma_case",      -- ga?: comma,case
          "to_phrase_case",     -- ga?: Phrase case
          "to_camel_case",      -- gac: camelCase
          "to_pascal_case",     -- gap: PascalCase
          "to_title_case",      -- gat: Title Case
          "to_path_case",       -- ga?: path/case
          "to_upper_phrase_case", -- ga?: UPPER PHRASE CASE
          "to_lower_phrase_case", -- ga?: lower phrase case
        }
      })

    end,
    -- Let the plugin register its own default keymaps automatically
  },
}