# in nix repl by running the following command you cal import the flake 
# nix-repl> :lf . 
{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-23.11"; };

    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = {
          myHello = pkgs.hello;

          myHello2 = pkgs.stdenv.mkDerivation {
            name = "myHello2";
            src = ./.; # current directory
            nativeBuildInputs =
              [ pkgs.hello ]; # pkgs are available during run time
            # buildInputs = [ pkgs.hello ]; # pkgs are available in the build environment
            dontFixup = true; # tell derivations to not fixup the output
            installPhase = ''
              # hello > $out # example of buildInputs usage 

                      cp -r ./script.sh $out # example of nativeBuildInputs usage
            '';
          };
        };

        devShells = {
          myShell = pkgs.mkShell {
            name = "myShell";
            buildInputs = [ packages.myHello ];
          };
        };
      });
}

