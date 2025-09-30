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

    # --- MODIFIED SECTION ---
    # The logic is now entirely inside the buildPhase shell script.
    buildPhase = ''
            runHook preBuild

            # Change directory into the `src` folder to make all paths simpler.
            cd src

            # A shell function to find subdirectories and format them as markdown links.
            # Arg 1: The path to scan (e.g., "Linux/Installation")
            # Arg 2: The indentation string (e.g., "  ")
            generate_sub_links() {
              local path="$1"
              local indent="$2"
              # Find all directories exactly one level deep, sort them, and process each one.
              find "$path" -mindepth 1 -maxdepth 1 -type d | sort | while read -r dir; do
                local name=$(basename "$dir")
                echo "$indent- [$name]($dir/readme.md)"
              done
            }

            echo "Appending generated content to SUMMARY.md..."

            # Use a temporary file to build the new content
            cat > linux_summary.md <<- EOF
      # DataBase

      $(generate_sub_links "DataBase" "")

      # Deployment

      $(generate_sub_links "Deployment" "")

      # Linux

      - [Installation](./Linux/Installation/readme.md)
      $(generate_sub_links "Linux/Installation" "    ")
      - [Tools](./Linux/Tools/readme.md)
      $(generate_sub_links "Linux/Tools" "    ")
      EOF

            # Now, append the generated content to the main SUMMARY.md file.
            cat linux_summary.md >> SUMMARY.md

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
