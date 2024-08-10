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
  inherit (lib) optionals lists;

  # Define the `mkImport` function
  mkImport =
    # Use `optionals` to conditionally apply the import logic
    # If `ListOfPrograms` is not empty, proceed to map over the list and import each program
    optionals ((lists.length ListOfPrograms) > 0) lists.map (
      sProgram: let
        rPath = name: (import /${path}/${name}); # Constructs the full path and imports the module
      in
        rPath sProgram # Apply the `rPath` function to each program in `ListOfPrograms`
    )
    ListOfPrograms; # The list to map over
in
  mkImport
