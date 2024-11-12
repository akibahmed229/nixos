{
  pkgs,
  self,
  lib,
  config,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
  path = mkRelativeToRoot "modules/predefiend/nixos";
in {
  /*
  Specialisation is a way to configure your system based on your needs.
  It will Create boot entry for each specialisation and will allow you to switch between them.
  */
  specialisation = {
    "DevOPS".configuration = {
      imports = mkImport {
        inherit path;
        ListOfPrograms = ["kubernetes"];
      };
    };

    "Gaming".configuration = {
      imports = mkImport {
        inherit path;
        ListOfPrograms = ["gaming"];
      };
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch-spec" ''
      if [ $# -ne 1 ]; then
        echo "Usage: switch-spec <specialisation>"
        exit 1
      fi

      sudo /nix/var/nix/profiles/system/specialisation/$1/bin/switch-to-configuration switch
    '')
  ];

  environment.sessionVariables = lib.mkIf (config.specialisation != {}) {
    SPECIALISATION = "NONE";
  };
}
