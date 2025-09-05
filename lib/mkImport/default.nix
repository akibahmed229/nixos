/*
mkImport: Import a list of modules from a given base path.

Usage:
  mkImport {
    lib = pkgs.lib;
    path = ./modules;
    ListOfPrograms = [ "programA" "programB" ];
  }

Example:
  If `path = ./modules` and `ListOfPrograms = [ "foo" "bar" ]`,
  it will try to import:
    ./modules/foo/default.nix
    ./modules/bar/default.nix
*/
{lib}: {
  path ? throw "path is required",
  ListOfPrograms ? [],
  ...
}: let
  inherit (lib) lists concatStringsSep flatten;
  inherit (builtins) trace pathExists;

  ifFileExists = file:
    if pathExists file
    then import file
    else throw "File not found: ${file}";

  flattenListOfPrograms = flatten ListOfPrograms;

  modules =
    lists.map (name: ifFileExists (path + "/${name}"))
    flattenListOfPrograms;
in
  trace "Importing modules: ${concatStringsSep ", " flattenListOfPrograms}"
  modules
