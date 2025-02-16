{_, ...}: let
  listOfDrive = [
    # {
    #   device = "sda1";
    #   mountPoint = "/mnt/sda1";
    # }
    {
      device = "sda2";
      mountPoint = "/mnt/sda2";
    }
  ];

  listOfDriveConfig =
    builtins.listToAttrs
    (map (drive: {
        name = "${drive.device}";
        value = {
          "path" = "${drive.mountPoint}";
          "comment" = "${drive.device}";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      })
      listOfDrive);
in {
  # Enabling samba file sharing over local network
  services.samba = {
    enable = true; # Dont forget to set a password for the user with smbpasswd -a ${user}
    settings = listOfDriveConfig;
    openFirewall = true;
  };
}
