{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
      (vaapiIntel.override {enableHybridCodec = true;}) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [intel-vaapi-driver]; # For older processors. LIBVA_DRIVER_NAME=i965
  };

  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Optionally, set the environment variable

  /*
  * 12th Gen (Alder Lake)
    * $ nix-shell -p pciutils --run "lspci -nn | grep VGA"
    * 00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-UP3 GT2 [Iris Xe Graphics] [8086:46a8] (rev 0c)

  * In this example, "46a8" is the device ID. You can then add this to your configuration and reboot:

   * boot.kernelParams = [ "i915.force_probe=<device ID>" ]; # in your hardware-configuration
  */
}
