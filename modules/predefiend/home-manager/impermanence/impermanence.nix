{ pkgs, inputs, user, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist/home/${user}" = {
    directories = [
      "Desktop"
      "Downloads"
      "Music"
      "Pictures"
      "Public"
      "Documents"
      "Videos"
      "VirtualBox VMs"
      "flake"
      "Android"
      ".docker"
      ".cache" # is persisted, but kept clean with systemd-tmpfiles, see below
      { directory = ".gnupg"; mode = "0700"; }
      { directory = ".ssh"; mode = "0700"; }
      { directory = ".config"; mode = "0700"; }
      { directory = ".mozilla"; mode = "0700"; }
      { directory = ".nixops"; mode = "0700"; }
      { directory = ".tmux"; mode = "0700"; }
      { directory = ".local/share/keyrings"; mode = "0700"; }
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
      ".local/share/direnv"

    ];
    files = [
      ".screenrc"
      ".zshrc"
      ".zshenv"
      #".zsh_history"
      #".gitconfig"
    ];
    allowOther = true;
  };

  #systemd.user.tmpfiles.rules = [
  #  /*
  #    clean old contents in home cache dir
  #    (it's persisted to avoid problems with large files being loaded into the tmpfs)
  #  */
  #  "e %h/.cache 755 ${user}  ${user} - - - 7d"

  #  # exceptions
  #  "x %h/.cache/rbw"
  #  "x %h/.cache/borg" # caches checksums of file chunks for deduplication
  #];
}
