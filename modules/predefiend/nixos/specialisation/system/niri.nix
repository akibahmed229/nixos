{
  self,
  user,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  specialisation = {
    "Niri".configuration = {
      imports = map mkRelativeToRoot [
        "home-manager/niri"
      ];

      home-manager.users.${user} = {
        imports = map mkRelativeToRoot [
          "home-manager/niri/home.nix"
        ];
      };
    };
  };
}
