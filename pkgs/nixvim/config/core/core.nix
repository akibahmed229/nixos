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
        key = "<C-y>";
        action = "ggVGy";
        options.desc = "Yank Current Buffer";
      }
      {
        mode = "n";
        key = "<leader>wv";
        action = "<cmd>vertical split<CR>";
        options.desc = "Vertical window split";
      }
      {
        mode = "n";
        key = "<leader>wh";
        action = "<cmd>horizontal split<CR>";
        options.desc = "Horizontal window split";
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
        options.desc = "Page down";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
        options.desc = "page up";
      }
      {
        mode = "i";
        key = "<C-c>";
        action = "<Esc>";
        options.desc = "Escep";
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
      providers.wl-copy.enable = true;
    };

    opts = {
      nu = true;
      number = true;
      relativenumber = true;

      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;

      smartindent = true;
      spell = true;
      wrap = true;

      swapfile = false;
      backup = false;
      # undodir = os.getenv("HOME") .. "/.vim/undodir";
      undofile = true;

      hlsearch = false;
      incsearch = true;

      termguicolors = true;

      scrolloff = 8;
      signcolumn = "yes";

      updatetime = 50;
      colorcolumn = "80";

      # autoindent = true;
      # smartcase = true;
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
