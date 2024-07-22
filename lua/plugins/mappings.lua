return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- do not hijack kill-line in terminal
        t = {
          ["<C-K>"] = false,
        },
        -- show LSP references in Telescope
        n = {
          ["<Leader>lt"] = {
            function() require("telescope.builtin").lsp_references() end,
            desc = "Telescope references",
          },
        },
        --
        -- and use a dedicated shortcut to show aerial
      },
    },
  },
}
