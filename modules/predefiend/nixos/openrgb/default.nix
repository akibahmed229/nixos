{
  pkgs,
  self,
  ...
}: {
  services.udev.packages = [pkgs.openrgb];
  boot.kernelModules = ["i2c-dev"]; # An acronym for the “Inter-IC” bus, a simple bus protocol which is widely used where low data rate communications suffice.
  hardware.i2c.enable = true;

  # Setting For OpenRGB
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "intel";
    server.port = 9999;
  };

  environment.systemPackages = [
    self.packages.${pkgs.system}.toggleRGB # Toggle RGB custom package
  ];
}
