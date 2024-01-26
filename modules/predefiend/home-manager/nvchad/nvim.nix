{ inputs
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
    vimAlias = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      ripgrep
      fzf
      clangd
      nixpkgs-fmt
    ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = "${pkgs.callPackage ../../../../pkgs/nvchad/default.nix {} }";
    };
  };
}
