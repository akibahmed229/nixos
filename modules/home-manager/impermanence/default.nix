{
  lib,
  config,
  inputs,
  ...
  # Note: inputs is no longer strictly needed here unless used elsewhere
}:
with lib; let
  cfg = config.hm.impermanence;
in {
  options.hm.impermanence = {
    enable = mkEnableOption "Home Manager persistence configuration";

    persistentStoragePath = mkOption {
      type = types.str;
      default = "/persist";
      description = "The root path where persistent data is stored.";
    };

    allowOther = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to set allowOther for the bind mount.";
    };
  };

  # imports = [inputs.impermanence.homeManagerModules.impermanence]; need to enable if don't use in nixos

  # config = mkIf cfg.enable {
  #   home.persistence."${cfg.persistentStoragePath}${config.home.homeDirectory}" = {
  #     allowOther = cfg.allowOther;

  #     directories = [
  #       "Desktop"
  #       "Downloads"
  #       "Music"
  #       "Pictures"
  #       "Public"
  #       "Documents"
  #       "Videos"
  #       "VirtualBox VMs"
  #       "Android"
  #       "Postman"
  #       "Games"
  #       ".vscode"
  #       ".docker"
  #       ".mysql"
  #       ".rustup"
  #       ".steam"
  #       ".elfeed"
  #       ".nixops"
  #       ".local/share/direnv"
  #       ".local/share/zed"
  #       ".local/zed.app"
  #       {
  #         directory = ".gnupg";
  #         mode = "0700";
  #       }
  #       {
  #         directory = ".ssh";
  #         mode = "0700";
  #       }
  #       {
  #         directory = ".config";
  #         mode = "0700";
  #       }
  #       {
  #         directory = ".mozilla";
  #         mode = "0700";
  #       }
  #       {
  #         directory = ".tmux";
  #         mode = "0700";
  #       }
  #       {
  #         directory = ".local/share/keyrings";
  #         mode = "0700";
  #       }
  #       ".local/share/nvim"
  #       ".local/share/TelegramDesktop"
  #       ".local/share/whatsapp-for-linux"
  #       ".local/share/Notepadqq"
  #       ".local/share/qBittorrent"
  #       ".local/share/zsh"
  #       ".local/share/flatpak"
  #       ".local/state/nvim"
  #       ".local/state/wireplumber"
  #       ".local/share/atuin"
  #       ".local/share/Steam"
  #       ".local/share/org.localsend.localsend_app"
  #       ".var/app/sh.ppy.osu"
  #       ".cache"
  #     ];

  #     files = [
  #       ".screenrc"
  #       ".mysql_history"
  #     ];
  #   };

  #   systemd.user.tmpfiles.rules = [
  #     "e %h/.cache 755 %u %g 7d"
  #     "x %h/.cache/rbw"
  #     "x %h/.cache/borg"
  #   ];
  # };
}
