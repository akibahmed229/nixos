{ lib, config, pkgs, ... }:
let
  cfg = config.user;
  shell = pkgs.zsh;
  link = [ "/share/zsh" "/tmp" "/home/${cfg.userName}" ];
  checkUserFun = user: if user == "akib" then shell else pkgs.bash;
in
{
  options = {
    user = {
      enable = lib.mkEnableOption "Enable the main user module";
      userName = lib.mkOption {
        description = "The user to be created";
        default = "user";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s
    sops.secrets."myservice/my_subdir/root_secret".neededForUsers = lib.mkIf (cfg.userName == "akib") true; # decrypt the secret to /run/secrets-for-users
    users.users.root.hashedPasswordFile = lib.mkIf (cfg.userName == "akib") config.sops.secrets."myservice/my_subdir/root_secret".path;

    programs.zsh.enable = true;
    users.defaultUserShell = checkUserFun cfg.userName;
    environment.shells = [ (checkUserFun cfg.userName) ];
    environment.pathsToLink = if cfg.userName == "akib" then link else [ "/share/bash" "/tmp" ];
    sops.secrets."myservice/my_subdir/my_secret".neededForUsers = lib.mkIf (cfg.userName == "akib") true;
    users.mutableUsers = lib.mkIf (config.users.users.${cfg.userName}.hashedPasswordFile != { }) true;
    users.users.${cfg.userName} = {
      isNormalUser = true;
      hashedPasswordFile = lib.mkIf (cfg.userName == "akib") config.sops.secrets."myservice/my_subdir/my_secret".path;
      hashedPassword = lib.mkIf (cfg.userName != "akib") "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
      #initialPassword = "123456"
      extraGroups = [ "networkmanager" "wheel" "systemd-journal" "docker" "video" "audio" "scanner" "libvirtd" "kvm" "disk" "input" "plugdev" "adbusers" "flatpak" "plex" ];
      packages = with pkgs; [
        wget
        thunderbird
        vlc
      ];
    };
    security.sudo.wheelNeedsPassword = true; # User does not need to give password when using sudo.
  };
}
