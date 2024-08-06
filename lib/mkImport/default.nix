{lib}: {
  path ? throw "path is required",
  ListOfPrograms ? [],
  ...
}: let
  mkImport =
    lib.optionals ((lib.lists.length ListOfPrograms) > 0) lib.lists.map (
      sProgram: let
        rPath = name: (import /${path}/${name}); # path to the module
      in
        rPath sProgram # loop through the apps and import the module
    )
    ListOfPrograms;
in
  mkImport
