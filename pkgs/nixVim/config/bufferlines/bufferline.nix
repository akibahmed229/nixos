{
  plugins.bufferline = {
    enable = true;
    numbers = "none";
    diagnostics = "nvim_lsp";
    separatorStyle = "slope";
  };
  keymaps = [
    {
      mode = "n";
      key = "<tab>";
      action = "<Cmd>BufferLineCycleNext<CR>";
      options.desc = "Next Buffer";
    }
    {
      mode = "n";
      key = "<S-tab>";
      action = "<Cmd>BufferLineCyclePrev<CR>";
      options.desc = "Previous Buffer";
    }
  ];
}
