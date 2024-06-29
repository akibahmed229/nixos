{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "HDMI-A-2";
        };
        width = mkOption {
          type = types.int;
          example = 1920;
        };
        height = mkOption {
          type = types.int;
          example = 1080;
        };
        refreshRate = mkOption {
          type = types.int;
          default = 75;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
        };
      };
    });
    default = [];
  };

  config = {
    monitors = [
      {
        name = "HDMI-A-2";
        width = 1920;
        height = 1080;
        refreshRate = 75;
        x = 0;
        y = 0;
        enabled = true;
      }
    ];
  };
}
