/*
* overlay for latest custom kernel
* https://github.com/NixOS/nixpkgs/blob/e6db435973160591fe7348876a5567c729495175/pkgs/os-specific/linux/kernel/generic.nix#L11-L56
*/
{inputs, ...}: (final: prev: {
  linuxPackages_latest = prev.linuxPackages_latest.extend (
    self: super: {
      kernel = super.kernel.override {
        # Custom kernel configuration
        structuredExtraConfig = with inputs.nixpkgs.lib.kernel; {
          # enable Intel-specific options
          CONFIG_INTEL_PMC_CORE = yes;
          CONFIG_PERF_EVENTS_INTEL_UNCORE = yes;
          CONFIG_DRM_I915 = yes;
          CONFIG_DRM_I915_GVT_KVMGT = yes;
          CONFIG_INTEL_POWERCLAMP = yes;
          CONFIG_X86_ACPI_CPUFREQ = yes;

          # disable AMD-specific options
          CONFIG_AMD_NB = option no;
          CONFIG_X86_AMD_PLATFORM_DEVICE = option no;
          CONFIG_CPU_SUP_AMD = option no;
          CONFIG_DRM_AMDGPU = option no;
          CONFIG_AMD_IOMMU = option no;
          CONFIG_AMD_XGBE = option no;
          CONFIG_FB_RADEON = option no;
          CONFIG_DRM_RADEON = option no;
          CONFIG_X86_AMD_PSTATE = option no;
          CONFIG_KVM_AMD = option no;
          CONFIG_HW_RANDOM_AMD = option no;
          CONFIG_AGP_AMD64 = option no;
        };
        # Add custom kernel patches from the patches directory
        kernelPatches = [
          {
            name = "Improves in memory performance & reducing the kernel boot time";
            patch = ./patches/acpi-slab-hwcache-align.patch;
          }
        ];
        ignoreConfigErrors = true;
      };
    }
  );
})
