{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # RGB lighting control.
    openrgb-with-all-plugins
    openrgb-plugin-hardwaresync
  ];

  # Setting For OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };
}
