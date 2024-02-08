{ pkgs, inputs, user, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist/home/${user}" = {
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "VirtualBox VMs"
      "Android"
      "flake"
      ".docker"
      ".mozilla"
      ".tmux"
      ".gnupg"
      ".ssh"
      ".nixops"
      ".config"
      ".local"
      ".cache" # is persisted, but kept clean with systemd-tmpfiles, see below
    ];
    files = [
      ".screenrc"
      ".zshrc"
      ".zshenv"
      ".zsh_history"
      ".gitconfig"
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
