{
  pkgs,
  ...
}:

{
  plugins.telescope = {
    enable = true;
    settings.defaults = {
      file_ignore_patterns = [
        "^.git/"
        "^output/"
        "^target/"
      ];
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>lua require('telescope.builtin').find_files({hidden = true})<CR>";
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>lua require('telescope.builtin').live_grep({hidden = true})<CR>";
      options.desc = "Grep Files";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>lua require('telescope.builtin').buffers()<CR>";
      options.desc = "Find Buffer";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>lua require('telescope.builtin').help_tags()<CR>";
      options.desc = "Find Help";
    }
    {
      mode = "n";
      key = "<leader>fd";
      action = "<cmd>lua require('telescope.builtin').diagnostics()<CR>";
      options.desc = "Find Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>ft";
      action = "<cmd>lua require('telescope.builtin').treesitter()<CR>";
      options.desc = "Find Treesitter";
    }
    {
      mode = "n";
      key = "<leader>fm";
      action = "<cmd>lua require('telescope.builtin').marks()<CR>";
      options.desc = "Find Marks";
    }
  ];
}
