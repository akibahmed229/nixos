let
  pkgs = import <nixpkgs> { };

  # can access through :
  # nix-instantiate name.nix
  # nix-store --realise $(nix-instantiate name.nix) # path of nix instantiate
  derv = builtins.derivation {
    name = "my-derivation";
    builder = "/bin/sh";
    system = "x86_64-linux";
    args = [ "-c" "echo hello > $out" ];
  };

  # can access through nix build --file name.nix
  runCmd = pkgs.runCommand "my-derivation" { } ''
    echo hello > $out
  '';

  mkDerivation = pkgs.stdenv.mkDerivation {
    name = "my-derivation";
    src = ./.;
    installPhase = ''
      echo hello > $out
    '';
  };
in
mkDerivation
