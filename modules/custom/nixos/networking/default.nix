# using nixos as a router: https://francis.begyn.be/blog/nixos-home-router
# Configures core networking parameters: gateway, DNS, domain, and static IP for primary interfaces.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.networking;

  # Helper function to convert a simplified address string ("IP/CIDR") into the NixOS format
  parseAddress = s: {
    address = head (splitString "/" s);
    prefixLength = toInt (last (splitString "/" s));
  };
in {
  # --- 1. Define Options ---
  options.nm.networking = {
    enable = mkEnableOption "Enable core networking configuration.";

    defaultGateway = mkOption {
      type = types.nullOr (types.attrsOf types.str);
      default = null;
      description = "Default gateway configuration (address and interface).";
      example = {
        address = "192.168.0.1";
        interface = "enp4s0";
      };
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The domain name of the system (e.g., example.com).";
      example = "example.com";
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [
        "1.1.1.1" # Cloudflare Primary
        "1.0.0.1" # Cloudflare Secondary
      ];
      description = "List of DNS nameservers to use.";
    };

    enableNetworkManager = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable NetworkManager.";
    };

    macAddressStrategy = mkOption {
      type = types.enum ["random" "stable" "none"];
      default = "random";
      description = "MAC address strategy for NetworkManager (random, stable, or none).";
    };

    interfaces = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      description = "Static IPv4 addresses for primary interfaces (interfaceName = [\"IP/CIDR\", ...]).";
      example = {"enp4s0" = ["192.168.0.111/24"];};
    };
  };

  /*
  you can use the module as follow:
    nm.networking = {
      enable = true;
      domain = "${user}lab";

      defaultGateway = {
        address = "192.168.0.1";
        interface = "enp4s0";
      };

      # Static IPs for physical interfaces
      interfaces = {
        "enp4s0" = ["192.168.0.111/24"];
        "wlp0s20f0u4" = ["192.168.0.179/24"];
      };
    };

  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Basic Networking and DNS
    networking = {
      defaultGateway = cfg.defaultGateway;
      nameservers = cfg.nameservers;
      domain = mkIf (cfg.domain != null) cfg.domain;
      search = mkIf (cfg.domain != null) [cfg.domain]; # Set search domain equal to the domain name
    };

    # 2.2 NetworkManager
    networking.networkmanager = mkIf cfg.enableNetworkManager {
      enable = true;
      wifi.macAddress = cfg.macAddressStrategy;
      ethernet.macAddress = cfg.macAddressStrategy;
    };

    # 2.3 Interface Configuration
    networking.interfaces = let
      # Convert the simplified attribute set of interfaces into the required NixOS format
      interfaceConfigs =
        mapAttrs (
          interfaceName: addressList: {
            name = interfaceName;
            ipv4.addresses = map parseAddress addressList;
          }
        )
        cfg.interfaces;
    in
      interfaceConfigs;
  };
}
