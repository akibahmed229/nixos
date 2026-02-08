{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.gpu;

  # --- Driver Definitions ---
  # We define these separately so we can mix/match them
  drivers = {
    intel = {
      extraPackages = with pkgs; [
        intel-media-driver # Broadwell+ (iHD)
        vpl-gpu-rt # QSV
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [intel-media-driver];
      env = {LIBVA_DRIVER_NAME = "iHD";};
    };

    amd = {
      extraPackages = with pkgs; [
        amdvlk
        libva-mesa-driver
        mesa.drivers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        amdvlk
        libva-mesa-driver
        mesa.drivers
      ];
      env = {}; # AMD usually autodetects well
    };

    nvidia = {
      # The main driver is handled by hardware.nvidia.package,
      # but we might want extra tools like cuda here if needed.
      extraPackages = [pkgs.nvidiaPackages.cuda_latest];
      extraPackages32 = [];
      env = {};
    };
  };
in {
  # --- 1. Define Options ---
  options.nm.gpu = {
    enable = mkEnableOption "Enable graphics hardware acceleration and drivers";

    # --- Intel Config ---
    intel = {
      enable = mkEnableOption "Enable Intel GPU drivers (iGPU or dGPU)";
      busId = mkOption {
        type = types.str;
        default = "";
        description = "Bus ID of the Intel GPU (required for NVIDIA PRIME). Example: PCI:0@0:2:0";
      };
    };

    # --- AMD Config ---
    amd = {
      enable = mkEnableOption "Enable AMD GPU drivers (iGPU or dGPU)";
      busId = mkOption {
        type = types.str;
        default = "";
        description = "Bus ID of the AMD GPU (required for NVIDIA PRIME). Example: PCI:5@0:0:0";
      };
    };

    # --- NVIDIA Config ---
    nvidia = {
      enable = mkEnableOption "Enable NVIDIA GPU drivers";
      busId = mkOption {
        type = types.str;
        default = "";
        description = "Bus ID of the NVIDIA GPU. Example: PCI:1@0:0:0";
      };

      # Optional: Allow toggling sync vs offload
      useSyncMode = mkOption {
        type = types.bool;
        default = false;
        description = "Use NVIDIA Sync mode (high performance, high power) instead of Offload.";
      };
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
    # 2.1 Core Graphics Setup
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      # Dynamically merge drivers based on enabled flags
      extraPackages =
        (
          if cfg.intel.enable
          then drivers.intel.extraPackages
          else []
        )
        ++ (
          if cfg.amd.enable
          then drivers.amd.extraPackages
          else []
        )
        ++ (
          if cfg.nvidia.enable
          then drivers.nvidia.extraPackages
          else []
        );

      extraPackages32 =
        (
          if cfg.intel.enable
          then drivers.intel.extraPackages32
          else []
        )
        ++ (
          if cfg.amd.enable
          then drivers.amd.extraPackages32
          else []
        )
        ++ (
          if cfg.nvidia.enable
          then drivers.nvidia.extraPackages32
          else []
        );
    };

    # 2.2 Session Variables
    environment.sessionVariables =
      (
        if cfg.intel.enable
        then drivers.intel.env
        else {}
      )
      // (
        if cfg.amd.enable
        then drivers.amd.env
        else {}
      )
      // (
        if cfg.nvidia.enable
        then drivers.nvidia.env
        else {}
      );

    # 2.3 NVIDIA Specific Configuration
    services.xserver.videoDrivers = mkIf cfg.nvidia.enable ["nvidia"];

    hardware.nvidia = mkIf cfg.nvidia.enable {
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = true; # Open source kernel modules (Turing+)
      modesetting.enable = true;

      powerManagement = {
        enable = true;
        finegrained = true; # Saves power on offload mode
      };

      # 2.4 Hybrid Graphics (PRIME) Logic
      # Only enable PRIME if NVIDIA + (Intel OR AMD) is enabled
      prime = lib.mkMerge [
        {
          # NVIDIA Bus ID is always required
          nvidiaBusId = cfg.nvidia.busId;

          # Mode Selection: Sync (Performance) vs Offload (Battery)
          sync.enable = cfg.nvidia.useSyncMode;

          offload = {
            enable = !cfg.nvidia.useSyncMode;
            enableOffloadCmd = !cfg.nvidia.useSyncMode;
          };
        }

        (lib.mkIf cfg.intel.enable {
          intelBusId = cfg.intel.busId;
        })

        (lib.mkIf cfg.amd.enable {
          intelBusId = cfg.amd.busId;
        })
      ];
    };

    # 3. Apply kernel parameters
    boot.kernelParams = cfg.kernelParams;
  };
}
