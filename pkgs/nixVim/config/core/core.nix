{
  config = {
    globals = {
      mapleader = " ";
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
      loaded_python_provider = 0;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>bw<CR>";
        options.desc = "Quit Buffer";
      }
      {
        mode = "n";
        key = "<C-s>";
        action = "<cmd>w<CR>";
        options.desc = "Save Current Buffer";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }
    ];

    clipboard = {
      register = "unnamedplus";
    };

    opts = {
      autoindent = true;
      expandtab = true;
      number = true;
      relativenumber = true;
      shiftwidth = 4;
      smartcase = true;
      softtabstop = 4;
      spell = true;
      tabstop = 4;
      wrap = true;
    };

    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2";
      }
    ];

    colorschemes.gruvbox.enable = true;
  };
}
