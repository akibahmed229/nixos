{ config
, pkgs
, lib
, ...
}:
let
  nvimConfig = "${config.home.homeDirectory}/.config/flake/modules/predefiend/home-manager/nvim/nvim";
  nvimTarget = "${config.home.homeDirectory}/.config/nvim";
in
{
  home.activation.symlinkQuickshellConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn "${nvimConfig}" "${nvimTarget}"
  '';

  home.packages = with pkgs; [
    # Nvim stuff
    neovim-unwrapped
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    lua-language-server
    vscode-langservers-extracted
    typescript-language-server
    intelephense
    vimPlugins.nvim-treesitter.withAllGrammars
  ];
}

