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
    ## Core
    neovim-unwrapped
    ripgrep
    git

    ## Nix
    nixd # Nix language server
    alejandra # Nix formatter

    ## Python
    pyright # LSP
    black # Formatter
    isort # Import sorter

    ## C / C++
    clang-tools # clangd, clang-format, etc.
    cmake # Build system
    bear # Generate compile_commands.json (optional)

    ## Rust
    rust-analyzer # Rust LSP

    ## Go
    gopls # Go LSP

    ## PHP
    intelephense # PHP LSP

    ## Dart
    (lib.hiPrio dart) # Dart SDK (hiPrio avoids collisions)

    ## Web / Frontend
    (lib.lowPrio prettier) # Prettier formatter (lowPrio avoids conflicts)
    typescript-language-server # TS/JS LSP
    vscode-langservers-extracted # HTML, CSS, JSON, ESLint

    ## Shell
    bash-language-server # Bash LSP

    ## YAML
    yaml-language-server # YAML LSP

    ## Lua
    lua-language-server # Lua LSP

    ## Terraform
    terraform-ls
  ];
}
