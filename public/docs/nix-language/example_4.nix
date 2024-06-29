let
  myusers = [
    {
      whoami = "akib";
      isNormalUser = true;
      hashedPassword = "afaffajfag09gaglR9393t293486-n#4#315105FK90rhtr-30tq3t-t0-t-3t3-taffgag/";
      extraGroups = ["plugdev" "adbusers" "flatpak" "plex"];
      enabled = true;
    }
    {
      whoami = "mafia";
      isNormalUser = true;
      hashedPassword = "afaffajfag09gaglR9393t293486-n#4#315105FK90rhtr-30tq3t-t0-t-3t3-taffgag/";
      extraGroups = ["flatpak" "plex"];
      enabled = true;
    }
  ];
in
  builtins.listToAttrs (builtins.map
    (user: {
      name = user.whoami;
      value = {
        inherit (user) hashedPassword;
        inherit (user) extraGroups;
        inherit (user) isNormalUser;
        inherit (user) enabled;
      };
    })
    myusers)
