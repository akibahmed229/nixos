{ self
, inputs
, pkgs
, ...
}:
{
  home = {
    packages = with pkgs; [
      neovide
      rust-analyzer
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
      source = builtins.unsafeDiscardOutputDependency ''${self.packages.${pkgs.system}.nvchad}'';
    };
  };
}
