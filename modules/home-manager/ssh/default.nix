{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.ssh;
in {
  options.hm.ssh = {
    enable = mkEnableOption "SSH client configuration";

    addKeysToAgent = mkOption {
      type = types.str;
      default = "yes";
      description = "Whether to add keys to the SSH agent (yes, no, confirm, or ask).";
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      # The new way: apply the setting to all hosts (*)
      matchBlocks."*" = {
        addKeysToAgent = cfg.addKeysToAgent;
      };

      extraConfig = builtins.readFile ./config;
    };

    home.file.".ssh/config".executable = false;
  };
}
