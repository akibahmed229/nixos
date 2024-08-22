{
  inputs,
  user,
  config,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist${config.home.homeDirectory}" = {
    directories = [
      "Desktop"
      "Downloads"
      "Music"
      "Pictures"
      "Public"
      "Documents"
      "Videos"
      "VirtualBox VMs"
      "Android"
      "Postman"
      "Games"
      ".vscode"
      ".docker"
      ".mysql"
      ".rustup"
      ".steam"
      ".elfeed"
      ".cache" # is persisted, but kept clean with systemd-tmpfiles, see below
      {
        directory = ".gnupg";
        mode = "0700";
      }
      {
        directory = ".ssh";
        mode = "0700";
      }
      {
        directory = ".config";
        mode = "0700";
      }
      {
        directory = ".mozilla";
        mode = "0700";
      }
      {
        directory = ".nixops";
        mode = "0700";
      }
      {
        directory = ".tmux";
        mode = "0700";
      }
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
      ".local/share/direnv"
      ".local/share/nvim"
      ".local/share/TelegramDesktop"
      ".local/share/whatsapp-for-linux"
      ".local/share/Notepadqq"
      ".local/share/qBittorrent"
      ".local/share/zsh"
      ".local/share/flatpak"
      ".local/state/nvim"
      ".local/state/wireplumber"
      ".local/share/atuin"
      ".local/share/Steam"
      ".local/share/zed"
      ".local/zed.app"
      ".local/share/org.localsend.localsend_app"
      ".var/app/sh.ppy.osu"
    ];
    files = [
      ".screenrc"
      #".zshrc"
      #".gitconfig"
      ".mysql_history"
    ];

    allowOther = true;
  };

  systemd.user.tmpfiles.rules = [
    /*
    clean old contents in home cache dir
    (it's persisted to avoid problems with large files being loaded into the tmpfs)
    */
    "e %h/.cache 755 ${user}  ${user} - - - 7d"

    # exceptions
    "x %h/.cache/rbw"
    "x %h/.cache/borg" # caches checksums of file chunks for deduplication
  ];
}
