{
  description = "LaTeX-DevShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    akibLibSrc = {
      url = "github:akibahmed229/nixos";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    akibLibSrc,
  }: let
    # --- 1. Library and Helpers ---
    akibLib = import "${akibLibSrc}/lib" {inherit (nixpkgs) lib;};
    inherit (akibLib) forAllSystems;

    # --- 2. Centralized Package Definition (DRY principle) ---
    # This is a function that takes 'pkgs' and returns the combined TeX Live set.
    # We define it once here and call it inside the forAllSystems loops.
    createTexlivePackages = pkgs:
      pkgs.texlive.combine {
        inherit
          (pkgs.texlive)
          scheme-small
          latexmk
          luatex
          biber
          amsmath
          graphics
          koma-script
          babel-german
          hyperref
          fontawesome5
          tcolorbox
          ;
      };

    # --- 3. Centralized App Definition ---
    # The watch app definition is also system-agnostic, so we define a function
    # that takes the system-specific texlive-packages and returns the app definition.
    createWatchAppDef = pkgs: texliveP: {
      type = "app";
      program = "${pkgs.writeShellApplication {
        name = "latex-watch";
        runtimeInputs = [texliveP];
        text = ''
          TARGET_FILE="''${1:-document.tex}"
          if [ ! -f "$TARGET_FILE" ]; then
              echo "Error: Target file '$TARGET_FILE' not found."
              echo "Usage: nix run '.#watch' -- [your-file.tex]"
              exit 1
          fi
          echo "Watching and continuously building '$TARGET_FILE'..."
          echo "Press Ctrl+C to stop."
          exec latexmk -pvc -f --pdf "$TARGET_FILE"
        '';
      }}/bin/latex-watch";
    };
  in {
    # ─── devShells Output ───────────────────────────────────────────────────
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      # Call the centralized function here
      texlive-packages = createTexlivePackages pkgs;
    in {
      default = pkgs.mkShell {
        name = "latex-shell-${system}";
        packages = [
          texlive-packages
          # Only include pkgs.skim if we are on a system that supports it (not i686-linux)
          (nixpkgs.lib.optional pkgs.stdenv.isDarwin pkgs.skim)
          pkgs.git
        ];
        shellHook = ''
          echo -e "\n✅ Entering LaTeX devshell\n"
          export PS1="[latex-shell] > "
          echo -e "You can now edit your .tex files."
          echo -e "To automatically recompile, run: 'latexmk -pvc your-document.tex'\n"
        '';
      };
    });

    # ─── apps Output ────────────────────────────────────────────────────────
    apps = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      # Call the centralized function here
      texlive-packages = createTexlivePackages pkgs;
      # Call the centralized app definition function
      watch-app-def = createWatchAppDef pkgs texlive-packages;
    in {
      watch = watch-app-def;
    });
  };
}
