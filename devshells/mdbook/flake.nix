{
  description = "Create Your Docs";

  inputs = {
    # Import nixpkgs from unstable branch
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Helper function
    akibLibSrc = {
      url = "github:akibahmed229/nixos";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    akibLibSrc,
    ...
  }: let
    lib = nixpkgs.lib;

    # Import Helper library functions
    akibLib = import "${akibLibSrc}/lib" {inherit lib;};

    # Utility that builds for all systems (x86_64-linux, aarch64-linux, etc.)
    inherit (akibLib) forAllSystems;
  in {
    # Define buildable packages per system
    packages = forAllSystems (
      system: let
        # Instantiate nixpkgs for the current system
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        # Default package: build mdBook site
        default = pkgs.stdenv.mkDerivation {
          pname = "my-project-docs";
          version = "0.1.0";

          # The docs live in ./docs
          src = ./docs;

          # Bring in mdBook + mdbook-cmdrun plugin
          nativeBuildInputs = with pkgs; [mdbook mdbook-cmdrun];

          buildPhase = ''
            runHook preBuild

            # Go into docs/src (mdBook expects `src` dir inside project root)
            cd src

            # Define a recursive function to walk subdirectories
            generate_links() {
              local path="$1"
              local indent="$2"

              # Iterate over all directories inside $path
              for dir in "$path"/*; do
                [ -d "$dir" ] || continue  # skip if not a directory
                name=$(basename "$dir")

                # Print a section header only for top-level dirs
                if [ "$indent" = "" ]; then
                  echo "# $name"
                fi

                # If directory has a readme.md, add a link to SUMMARY.md
                if [ -f "$dir/readme.md" ]; then
                  echo "$indent- [$name](./$dir/readme.md)"
                fi

                # Recurse into subdirectories with extra indentation
                generate_links "$dir" "  $indent"
              done
            }

            echo "Appending generated content to SUMMARY.md..."

            # Run the recursive generator, capture results in temp file
            cat > tmp_contents.md <<- EOF
            $(generate_links "./" "")
            EOF

            # Append generated links to SUMMARY.md
            cat tmp_contents.md >> SUMMARY.md

            echo "SUMMARY.md updated successfully."

            # Go back up and build the mdBook project
            cd ..
            mdbook build

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            # Install the generated HTML book into $out
            mkdir -p $out
            cp -R book/* $out/

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            maintainers = ["your name"];
            description = "My Personal Docs";
            platforms = platforms.all;
            license = licenses.gpl3;
          };
        };
      }
    );
  };
}
