{ self
, inputs
, pkgs
, ...
}:
{
  home = {
    packages = with pkgs; [
      neovide
    ];
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      ripgrep
      fzf
    ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ''${self.packages.${pkgs.system}.nvchad}'';
    };
  };
}
