{lib, ...}: {
  # Import the custom `mkSystem` function from the `mkSystem.nix` file
  mkSystem = import ./mkSystem;

  # Import the custom `mkImport` function from the `mkImport.nix` file
  # Pass `lib` as an argument to the `mkImport` function
  mkImport = import ./mkImport {inherit lib;};

  # Define `mkRelativeToRoot`, a helper function that appends a relative path from the current directory to the root directory
  mkRelativeToRoot = lib.path.append ../.;
}
