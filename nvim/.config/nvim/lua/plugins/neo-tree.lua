return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.group_empty_dirs = true
    end,
  },
}
