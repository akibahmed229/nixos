{
  path,
  ListOfPrograms ? [],
  ...
}: let
  mkImport =
    map
    (
      p: let
        rPath = name: (import /${path}/${name}); # path to the module
      in
        rPath p # loop through the apps and import the module
    )
    ListOfPrograms;
in
  mkImport
