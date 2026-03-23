-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local maven = require("config.maven")
maven.setup()

vim.keymap.set("n", "<leader>m", "<Nop>", { desc = "+maven" })
vim.keymap.set("n", "<leader>mm", function()
  maven.prompt()
end, { desc = "Maven goals" })
vim.keymap.set("n", "<leader>mt", function()
  maven.run("test")
end, { desc = "Maven test" })
vim.keymap.set("n", "<leader>mp", function()
  maven.run("package")
end, { desc = "Maven package" })
vim.keymap.set("n", "<leader>mi", function()
  maven.run("install")
end, { desc = "Maven install" })

vim.keymap.set("n", "<leader>mr", function()
  maven.spring_prompt()
end, { desc = "Spring run (profile)" })
