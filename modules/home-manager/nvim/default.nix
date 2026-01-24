{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.hm.nvim;
in {
  options.hm.nvim = {
    enable = mkEnableOption "Neovim configuration with live symlinking";

    srcPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/flake/modules/home-manager/nvim/config";
      description = "Absolute path to your Neovim config directory for live tinkering.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional LSPs, formatters, or tools to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        ## Core
        neovim-unwrapped
        ripgrep
        git

        ## Language Support & Tooling
        # Nix
        nixd
        alejandra

        # Python
        pyright
        black
        isort

        # C / C++
        clang-tools
        cmake
        bear

        # Rust & Go
        rust-analyzer
        gopls

        # PHP & Dart
        intelephense
        (lib.hiPrio dart)

        # Web / Frontend
        (lib.lowPrio prettier)
        typescript-language-server
        vscode-langservers-extracted

        # Shell / YAML / Lua / Terraform
        bash-language-server
        yaml-language-server
        lua-language-server
        terraform-ls
      ]
      ++ cfg.extraPackages;

    # Live Tinkering: Create a symlink to your physical config folder
    home.activation.symlinkNvimConfig = hm.dag.entryAfter ["writeBoundary"] ''
      targetDir="${config.xdg.configHome}/nvim"

      # Clean up existing config to avoid conflicts
      rm -rf "$targetDir"

      # Link to your live source path
      ln -sfn "${cfg.srcPath}" "$targetDir"
    '';
  };
}
