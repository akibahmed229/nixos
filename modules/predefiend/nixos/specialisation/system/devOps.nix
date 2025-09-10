{self, ...}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
  path = mkRelativeToRoot "modules/predefiend/nixos";
in {
  specialisation = {
    "DevOPS".configuration = {
      imports = mkImport {
        inherit path;
        ListOfPrograms = ["kubernetes"];
      };
    };
  };
}
