# Configures graphic hardware support for Intel, AMD, or NVIDIA, including
# drivers (OpenGL, Vulkan, VAAPI) and required kernel settings.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.gpu;

  # Define the required packages based on the selected vendor
  vendorPackages =
    {
      intel = with pkgs; {
        # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
        drivers = [
          intel-media-driver
          vpl-gpu-rt # or intel-media-sdk for QSV
        ];
        # For older processors. LIBVA_DRIVER_NAME=i965
        driversLegacy = [intel-vaapi-driver];
        # 32-bit support (usually for older or compatibility libraries)
        drivers32 = with pkgs.pkgsi686Linux; [intel-vaapi-driver];
        # Environment variable for VAAPI
        sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
        # Kernel parameters are optional for force_probe, but included here for reference
        kernelParams = [];
      };

      # AMD usually uses open-source drivers in the kernel, but needs Vulkan/VAAPI libs
      amd = with pkgs; {
        drivers = [
          amdvlk
          libva-mesa-driver
          mesa.drivers # Provides OpenGL and basic Vulkan support
        ];
        driversLegacy = [];
        drivers32 = with pkgs.pkgsi686Linux; [
          amdvlk
          libva-mesa-driver
          mesa.drivers
        ];
        sessionVariables = {};
        kernelParams = ["amdgpu.vm_fragment_size=9"]; # Common optimization
      };

      # NVIDIA requires proprietary drivers for full performance
      nvidia = {
        drivers = [pkgs.nvidiaPackages.cuda_latest]; # Use latest CUDA for a comprehensive setup
        driversLegacy = [];
        drivers32 = []; # Managed by the hardware.nvidia module implicitly
        sessionVariables = {};
        kernelParams = [];
      };
    }.${
      cfg.vendor
    };
in {
  # --- 1. Define Options ---
  options.nm.gpu = {
    enable = mkEnableOption "Enable graphics hardware acceleration and drivers.";

    vendor = mkOption {
      type = types.enum ["intel" "amd" "nvidia"];
      default = "intel";
      description = "The primary GPU vendor to configure drivers for (intel, amd, or nvidia).";
      example = "amd";
    };

    enableLegacyDrivers = mkOption {
      type = types.bool;
      default = false;
      description = "If true, includes legacy/older drivers (e.g., intel-vaapi-driver for i965).";
    };

    kernelParams = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Optional extra kernel parameters, such as 'i915.force_probe' for Intel.";
    };
  };

  /*
  * 12th Gen (Alder Lake)
    * $ nix-shell -p pciutils --run "lspci -nn | grep VGA"
    * 00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-UP3 GT2 [Iris Xe Graphics] [8086:46a8] (rev 0c)

  * In this example, "46a8" is the device ID. You can then add this to your configuration and reboot:

   * boot.kernelParams = [ "i915.force_probe=<device ID>" ]; # in your hardware-configuration
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 1. Enable core graphics stack
    hardware.graphics.enable = true;

    # 2. Add vendor-specific packages
    hardware.graphics.extraPackages =
      vendorPackages.drivers
      ++ (optionals cfg.enableLegacyDrivers vendorPackages.driversLegacy);

    # 3. Add 32-bit compatibility packages
    hardware.graphics.extraPackages32 = vendorPackages.drivers32;

    # 4. Set vendor-specific session variables (e.g., LIBVA_DRIVER_NAME)
    environment.sessionVariables = vendorPackages.sessionVariables;

    # 5. Apply kernel parameters
    boot.kernelParams = cfg.kernelParams ++ vendorPackages.kernelParams;

    # 6. Special handling for NVIDIA (requires separate module)
    # The actual NVIDIA driver activation is handled by the dedicated hardware.nvidia module.
    # We enable it conditionally here.
    hardware.nvidia = mkIf (cfg.vendor == "nvidia") {
      # Requires the 32-bit libraries for games and older apps
      package = config.boot.kernelPackages.nvidiaPackages.production;
      # Recommended to use the production branch for stability
      open = true;
      # NVIDIA devices often need additional configuration, like modesetting:
      modesetting.enable = true;
    };
  };
}
