{
  config,
  pkgs,
  lib,
  ...
}: let
  nvimConfig = "${config.home.homeDirectory}/.config/flake/modules/predefiend/home-manager/nvim/nvim";
  nvimTarget = "${config.home.homeDirectory}/.config/nvim";
in {
  home.activation.symlinkNvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${nvimConfig}" "${nvimTarget}"
  '';

  home.packages = with pkgs; [
    # Nvim stuff
    neovim-unwrapped
    ripgrep

    # Lsp server
    nixd # Nix language server.
    alejandra
    nodejs
    python3
    pyright
    clang-tools # provides clangd, clang-format, etc.
    cmake # if your project uses it
    bear # optional, auto-generate compile_commands.json
    rust-analyzer # for Rust
    gopls # for Go
    intelephense # for php
    dart # for dart
    bash-language-server
    yaml-language-server
    lua-language-server
    typescript-language-server

    vscode-langservers-extracted
  ];
}
