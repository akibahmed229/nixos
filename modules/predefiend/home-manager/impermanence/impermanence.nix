{ pkgs, inputs, user, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist/home" = {
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
      ".config/tmux"
      ".config/Thunar"
      ".config/Kvantum"
      ".config/nvim"
      ".config/sops"
      ".config/systemd"
      ".config/github-copilot"
      ".local/share/keyrings"
      ".local/share/direnv"
      ".local/share/nvim"
      ".local/share/Notepadqq"
      ".local/share/nwg-look"
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
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
