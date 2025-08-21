{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        separatorStyle = "slope";
        numbers = "none";
      };
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
  };
}
