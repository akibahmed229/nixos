/*
* mkImport Function:
    The function uses optionals to check if ListOfPrograms contains any elements. If the list is empty, it returns an empty list.
    If ListOfPrograms is not empty, it maps over the list using lists.map and applies the import logic to each program.
    For each program in ListOfPrograms, it constructs the full path using rPath and imports the corresponding module.
*/
{lib}: {
  # Define required and optional arguments with defaults
  path ? throw "path is required", # The base path where the files are located; throws an error if not provided
  ListOfPrograms ? [], # A list of programs to be imported; defaults to an empty list
  ...
}: let
  # Inherit utilities from the provided library (`lib`)
  inherit (lib) optionals lists concatStringsSep;
  inherit (builtins) trace pathExists;

  # Function to check if a file exists at the specified path
  ifFileExists = _path:
    if pathExists _path
    then import _path
    else throw "File not found: ${_path}";

  mkImport =
    # If `ListOfPrograms` is not empty, proceed to map over the list and import each program
    optionals ((lists.length ListOfPrograms) > 0) lists.map (
      sProgram: let
        rPath = name: (ifFileExists /${path}/${name}); # Constructs the full path and imports the module
      in
        rPath sProgram
    )
    ListOfPrograms; # The list to map over

  # Log the import information
  logImportInfo = trace "module found in: ${path}\nimporting modules: ${concatStringsSep ", " ListOfPrograms}";
in
  logImportInfo mkImport
