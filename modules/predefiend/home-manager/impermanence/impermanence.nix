{ pkgs, inputs, user, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist/home/${user}/" = {
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "VirtualBox VMs"
      "flake"
      ".gnupg"
      ".ssh"
      ".nixops"
      #".config"
      ".local/share/keyrings"
      ".local/share/direnv"
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
    ];
    files = [
      ".screenrc"
      ".zshrc"
      ".zshenv"
      #".zsh_history"
    ];
    allowOther = true;
  };
}
