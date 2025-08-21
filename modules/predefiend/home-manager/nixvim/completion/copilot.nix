{
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    settings = {
      panel = {
        enabled = false;
        autoRefresh = false;
        keymap = {
          jumpPrev = "[[";
          jumpNext = "]]";
          accept = "<CR>";
          refresh = "gr";
          open = "<M-CR>";
        };
        layout = {
          position = "left"; # | top | bottom | right
          ratio = 0.4;
        };
      };

      suggestion = {
        enabled = true;
        auto_trigger = true;
        debounce = 75;
        keymap = {
          accept = "<M-l>";
          accept_word = false;
          accept_line = false;
          next = "<M-]>";
          prev = "<M-[>";
          dismiss = "<C-]>";
        };
      };

      filetypes = {
        yaml = false;
        markdown = false;
        help = false;
        gitcommit = false;
        gitrebase = false;
        hgcommit = false;
        svn = false;
        cvs = false;
        "." = false;
      };

      copilotNodeCommand = "node"; # Node.js version must be > 18.x
      serverOptsOverrides = {};
    };
  };
}
