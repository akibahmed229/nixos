<<<<<<< HEAD
{
  pkgs,
  unstable,
  ...
}: {
  # Eableing OpenGl support
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with unstable.${pkgs.system}; [
      # your Open GL, Vulkan and VAAPI drivers
      # vpl-gpu-rt # or intel-media-sdk for QSV
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
=======
{pkgs, ...}: {
  # Eableing OpenGl support
  #hardware.opengl = {
  #  enable = true;
  #  driSupport32Bit = true;
  #  extraPackages = with unstable.${pkgs.system}; [
  #    # your Open GL, Vulkan and VAAPI drivers
  #    # vpl-gpu-rt # or intel-media-sdk for QSV
  #    intel-compute-runtime
  #    intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #    (vaapiIntel.override {enableHybridCodec = true;}) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #    vaapiVdpau
  #    libvdpau-va-gl
  #  ];
  #  extraPackages32 = with pkgs.pkgsi686Linux; [intel-vaapi-driver]; # For older processors. LIBVA_DRIVER_NAME=i965
  #};

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
>>>>>>> d02695d (changes)
      (vaapiIntel.override {enableHybridCodec = true;}) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [intel-vaapi-driver]; # For older processors. LIBVA_DRIVER_NAME=i965
  };
<<<<<<< HEAD

  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     intel-media-driver
  #     intel-media-sdk
  #   ];
  # };
  # environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Optionally, set the environment variable
=======
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Optionally, set the environment variable
>>>>>>> d02695d (changes)

  /*
  * 12th Gen (Alder Lake)
    * $ nix-shell -p pciutils --run "lspci -nn | grep VGA"
    * 00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-UP3 GT2 [Iris Xe Graphics] [8086:46a8] (rev 0c)

  * In this example, "46a8" is the device ID. You can then add this to your configuration and reboot:

   * boot.kernelParams = [ "i915.force_probe=<device ID>" ]; # in your hardware-configuration
  */
}
