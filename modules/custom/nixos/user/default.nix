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
    users.users.root.hashedPassword = "$6$V9VUyHMch1ZsocfS$zk5UFtOBFmIw/kc0mR9DIF03ooxkNHJLjDQbXbFO8lzN3spAWeszws4K1saheHEzIDxI6NNyr3xHyH.VQPHCs0";

    # shell settings 
    # Default Shell zsh
    programs.zsh.enable = true;
    users.defaultUserShell = checkUserFun cfg.userName;
    environment.shells = [ (checkUserFun cfg.userName) ];
    environment.pathsToLink = if cfg.userName == "akib" then link else [ "/share/bash" "/tmp" ];

    users.users.${cfg.userName} = {
      isNormalUser = true;
      hashedPassword =
        if (cfg.userName == "akib") then
          "$6$y5qxEUAdhGfuMjTA$7zd9DbLF3hw8BCi.pOGI0BYg2hUTcNnP8FkzJtXfOgBOD9fv8cmBlmbMbiaOTsfeqeLyRgY/XMxkADpBsBa4Z0"
        else # Default password is "123456"
          "$6$F24on0ukWanIJWvW$P7Ks7lUFBUUJj/ej54pSDcHt/6UgSMPcRQ57oxU2W4Ot9FpBA5guLp1D1.4WTWpQcB0Oo6AmkS64p0/f/65AY/";

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
