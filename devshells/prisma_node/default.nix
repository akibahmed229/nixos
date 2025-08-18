{
  description = "Web Development Environment with Node.js + Prisma";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # or your preferred channel
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux"; # adjust if needed
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "web-dev-shell";

      nativeBuildInputs = [pkgs.bashInteractive];

      buildInputs = with pkgs; [
        nodejs-slim
        nodePackages.npm
        nodePackages.prisma
        # optional extras
        nodePackages.typescript
        nodePackages.yarn
        nodePackages.pnpm
        prisma-engines
      ];

      shellHook = ''
        echo "Welcome to your Web Dev Environment 🚀"
        export PRISMA_MIGRATION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/migration-engine"
        export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
        export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
        export PRISMA_INTROSPECTION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/introspection-engine"
        export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"
      '';
    };
  };
}
