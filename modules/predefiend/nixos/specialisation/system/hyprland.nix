{
  self,
  user,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  specialisation = {
    "Hyprland".configuration = {
      imports = map mkRelativeToRoot [
        "home-manager/hyprland"
      ];

      home-manager.users.${user} = {
        imports = map mkRelativeToRoot [
          "home-manager/hyprland/home.nix"
        ];
      };
    };
  };
}
