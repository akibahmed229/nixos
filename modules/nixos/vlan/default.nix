# Configures specific VLAN interfaces and assigns their IP addresses.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.vlans;

  # Helper function to convert a simplified address string ("IP/CIDR") into the NixOS format
  parseAddress = s: {
    address = head (splitString "/" s);
    prefixLength = toInt (last (splitString "/" s));
  };

  # Convert simplified definition list into the two NixOS configurations (vlans and interfaces)
  vlanDefinitions = listToAttrs (map
    (def: let
      vlanName = "vlan${toString def.id}";
    in {
      name = vlanName;
      value = {
        # Defines the VLAN under networking.vlans
        vlanConfig = {
          id = def.id;
          interface = def.parentInterface;
        };
        # Defines the IP address under networking.interfaces
        interfaceConfig = {
          name = vlanName;
          ipv4.addresses = map parseAddress def.addresses;
        };
      };
    })
    cfg.definitions);
in {
  # --- 1. Define Options ---
  options.nm.vlans = {
    enable = mkEnableOption "Enable VLAN configuration.";

    definitions = mkOption {
      type = types.listOf (types.submodule ({name, ...}: {
        options = {
          id = mkOption {
            type = types.int;
            description = "The numeric ID of the VLAN.";
          };
          parentInterface = mkOption {
            type = types.str;
            description = "The physical parent interface (e.g., 'enp4s0') for the VLAN.";
          };
          addresses = mkOption {
            type = types.listOf types.str;
            description = "List of static IPv4 addresses for this VLAN interface (e.g., ['192.168.2.1/24']).";
          };
        };
      }));
      default = [];
      description = "List of VLAN definitions.";
    };
  };

  /*
  you can use the module as follow:
    # --- VLAN Configuration ---
    nm.vlans = {
      enable = true;
      definitions = [
        {
          id = 2;
          parentInterface = "enp4s0";
          addresses = ["192.168.2.1/24"];
        }
        {
          id = 3;
          parentInterface = "enp4s0";
          addresses = ["192.168.3.1/24"];
        }
      ];
    };
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Populate networking.vlans
    networking.vlans = mapAttrs (n: v: v.vlanConfig) vlanDefinitions;

    # 2.2 Populate networking.interfaces with VLAN IPs
    networking.interfaces = mapAttrs (n: v: v.interfaceConfig) vlanDefinitions;
  };
}
