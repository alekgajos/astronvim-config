return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- do not hijack kill-line in terminal
        t = {
          ["<C-K>"] = false,
          -- alternative Toggleterm trigger
          ["<C-\\>"] = { '<Cmd>execute v:count . "ToggleTerm"<CR>', desc = "Toggle terminal" },
          ["<C-N>"] = { "<Cmd>stopinsert<CR>", desc = "Enter normal mode in terminal" },
        },
        -- show LSP references in Telescope
        n = {
          ["<Leader>lt"] = {
            function() require("telescope.builtin").lsp_references() end,
            desc = "Telescope references",
          },
          -- alternative Toggleterm trigger
          ["<C-\\>"] = { '<Cmd>execute v:count . "ToggleTerm"<CR>', desc = "Toggle terminal" },
        },
        -- and use a dedicated shortcut to show aerial
      },
    },
  },
}
