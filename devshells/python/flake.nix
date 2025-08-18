{
  description = "General Python development environment (Nix flake template)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # or your preferred channel
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux"; # or "aarch64-linux" for ARM
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "python-dev-shell";

      # Core Python + pip + virtualenv
      packages = [
        (pkgs.python312.withPackages (ps:
          with ps; [
            pip
            setuptools
            wheel
            virtualenv
            ipython
            requests
          ]))
      ];

      shellHook = ''
        echo "🐍 Welcome to your Python Dev Environment!"
        echo "👉 Using Python $(python --version)"

        # Make VSCode / PyCharm pick up the .venv automatically
        venv="$(cd $(dirname $(which python)); cd ..; pwd)"
        ln -Tsf "$venv" .venv
      '';
    };
  };
}
