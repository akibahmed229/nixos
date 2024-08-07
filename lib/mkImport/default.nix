{lib}: {
  path ? throw "path is required",
  ListOfPrograms ? [],
  ...
}: let
  inherit (lib) optionals lists;

  mkImport =
    optionals ((lists.length ListOfPrograms) > 0) lists.map (
      sProgram: let
        rPath = name: (import /${path}/${name}); # path to the module
      in
        rPath sProgram # loop through the apps and import the module
    )
    ListOfPrograms;
in
  mkImport
