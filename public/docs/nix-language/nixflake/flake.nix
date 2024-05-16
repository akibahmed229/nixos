# in nix repl by running the following command you cal import the flake 
# nix-repl> :lf . 

{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-23.11";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        myHello = pkgs.hello;

        myHello2 = pkgs.stdenv.mkDerivation {
          name = "myHello2";
          src = ./.; # current directory
          nativeBuildInputs = [ pkgs.hello ]; # pkgs are available during run time
          # buildInputs = [ pkgs.hello ]; # pkgs are available in the build environment
          dontFixup = true; # tell derivations to not fixup the output
          installPhase = ''
            # hello > $out # example of buildInputs usage 

            cp -r ./script.sh $out # example of nativeBuildInputs usage
          '';
        };
      };

      devShells.${system} = {
        myShell = pkgs.mkShell {
          name = "myShell";
          buildInputs = [ pkgs.hello ];
        };
      };

    };
}
