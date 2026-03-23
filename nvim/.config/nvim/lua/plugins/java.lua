local function extend_unique(dst, items)
  dst = dst or {}
  for _, item in ipairs(items) do
    if not vim.tbl_contains(dst, item) then
      table.insert(dst, item)
    end
  end
  return dst
end

return {
  -- Make sure core Java tooling is installed via Mason.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = extend_unique(opts.ensure_installed, {
        "google-java-format",
        "lemminx", -- XML LSP (pom.xml)
      })
    end,
  },

  -- Better highlighting / indentation for Java.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = extend_unique(opts.ensure_installed, { "java", "xml" })
    end,
  },

  -- LSP for editing pom.xml and other XML files.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lemminx = {},
      },
    },
  },

  -- Format Java using google-java-format (installed via Mason above).
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.java = { "google-java-format" }
    end,
  },
}
