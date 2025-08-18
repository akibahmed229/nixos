{
  description = "C/C++ GTK 3 Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # or your preferred channel
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux"; # adjust if you're on aarch64, etc.
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "c-cpp-gtk3-devshell";

      packages = with pkgs; [
        gtk3
        pkg-config
        cmake
        clang-tools
      ];

      shellHook = ''
        echo "Welcome to the C/C++ GTK 3 development environment."
        export LD_LIBRARY_PATH=${pkgs.gtk3}/lib:$LD_LIBRARY_PATH
      '';
    };
  };
}
