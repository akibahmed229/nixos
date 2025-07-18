{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # your Open GL, Vulkan and VAAPI drivers
      vpl-gpu-rt # or intel-media-sdk for QSV

      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
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
