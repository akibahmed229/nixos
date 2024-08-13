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
          SCHED_MUQSS = yes;
          CONFIG_INTEL_PMC_CORE = yes;
          CONFIG_PERF_EVENTS_INTEL_UNCORE = yes;
          CONFIG_DRM_I915 = yes;
          CONFIG_DRM_I915_GVT_KVMGT = yes;
          CONFIG_INTEL_POWERCLAMP = yes;
          CONFIG_X86_ACPI_CPUFREQ = yes;
        };
        # Add custom kernel patches from the patches directory
        kernelPatches = [
          {
            name = "Improves in memory performance & reducing the kernel boot time";
            patch = inputs.self.lib.mkRelativeToRoot "public/patches/kernel/acpi-slab-hwcache-align.patch";
          }
        ];
        ignoreConfigErrors = true;
      };
    }
  );
})
