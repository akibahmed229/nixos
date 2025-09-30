{
  lib,
  stdenv,
  mdbook,
  ...
}: let
  custom = builtins.path {
    path = ./docs;
    name = "custom";
  };
in
  stdenv.mkDerivation {
    pname = "my-project-docs";
    version = "0.1.0";
    src = custom;
    nativeBuildInputs = [mdbook];

    buildPhase = ''
            runHook preBuild

            # Change directory into the `src` folder to make all paths simpler.
            cd src

            # A shell function to find subdirectories and format them as markdown links.
            # Arg 1: The path to scan (e.g., "Linux/Installation")
            # Arg 2: The indentation string (e.g., "  ")
            generate_links() {
              local path="$1"
              local indent="$2"

              # List only directories directly under $path
              for dir in "$path"/*; do
                [ -d "$dir" ] || continue
                name=$(basename "$dir")

                if [ "$indent" = "" ]; then
                  # Top-level directory -> section header
                  echo "# $name"
                fi

                # Always print a link for the current dir (if it has a readme.md)
                if [ -f "$dir/readme.md" ]; then
                  echo "$indent- [$name](./$dir/readme.md)"
                fi

                # Recurse into subdirectories with increased indent
                generate_links "$dir" "  $indent"
              done
            }

            echo "Appending generated content to SUMMARY.md..."

            # Use a temporary file to build the new content
            cat > tmp_contents.md <<- EOF
      $(generate_links "./" "")
      EOF

            # Now, append the generated content to the main SUMMARY.md file.
            cat tmp_contents.md >> SUMMARY.md

            echo "SUMMARY.md updated successfully."


            # Go back to the build root before running mdbook
            cd ..

            mdbook build
            runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R book/* $out/
      cp src/favicon.* $out/
      runHook postInstall
    '';

    meta = with lib; {
      description = "My Personal Docs";
      homepage = "https://github.com/akibahmed229/nixos";
      platforms = platforms.all;
      maintainers = [maintainers.akibahmed229];
      license = licenses.gpl3;
    };
  }
