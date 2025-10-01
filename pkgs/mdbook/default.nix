{
  lib,
  stdenv,
  mdbook,
  mdbook-cmdrun,
  ...
}:
stdenv.mkDerivation {
  pname = "my-project-docs";
  version = "0.1.0";
  src = ./docs;
  nativeBuildInputs = [mdbook mdbook-cmdrun];

  buildPhase = ''
    runHook preBuild

    # Change directory into the `src` folder to make all paths simpler.
    cd src

    # Define a recursive function to walk subdirectories
    generate_links() {
      local path="$1"
      local indent="$2"

      # Iterate over all directories inside $path
      for dir in "$path"/*; do
        [ -d "$dir" ] || continue   # skip if not a directory
        name=$(basename "$dir")

        # Print a section header only for top-level dirs
        if [ "$indent" = "" ]; then
        echo "# $name"
        fi

        # If directory has a readme.md, add a link to SUMMARY.md
        if [ -f "$dir/readme.md" ]; then
        echo "$indent- [$name](./$dir/readme.md)"
        fi

        # Recurse into subdirectories with increased indent
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
