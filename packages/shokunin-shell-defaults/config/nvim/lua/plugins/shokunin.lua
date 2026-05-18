-- Shokunin-specific plugin overrides. Edit, add, remove freely — this
-- file is yours after install.

return {
  -- AI: claude-code editor integration (ADR-0013). The underlying CLI
  -- is provided by shokunin-base. Configure the provider via
  -- ~/.config/shokunin/ai.env.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend" },
    keys = {
      { "<leader>a",  nil,                       desc = "AI/Claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",      desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",  desc = "Send selection", mode = "v" },
    },
  },

  -- Transparent background so the dynamic matugen theme (ADR-0007) and
  -- the terminal opacity from ghostty come through cleanly.
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
}
