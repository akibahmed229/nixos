/*
* overlay for latest custom kernel
* https://github.com/NixOS/nixpkgs/blob/e6db435973160591fe7348876a5567c729495175/pkgs/os-specific/linux/kernel/generic.nix#L11-L56
*/
{inputs, ...}: final: prev: let
  inherit (prev) lib;

  # Since 20.09 this is a part of lib.kernel
  option = x: x // {optional = true;};
in {
  linuxPackages_latest = prev.linuxPackages_latest.extend (
    self: super: {
      kernel = super.kernel.override {
        # Custom kernel configuration
        structuredExtraConfig = with lib.kernel; {
          EXPERT = yes; # PREEMPT_RT depends on it (in kernel/Kconfig.preempt).
          PREEMPT_RT = yes;
          PREEMPT_VOLUNTARY = lib.mkForce no; # PREEMPT_RT deselects it.
          RT_GROUP_SCHED = lib.mkForce (option no); # Removed by sched-disable-rt-group-sched-on-rt.patch.

          # enable Intel-specific options
          CONFIG_INTEL_PMC_CORE = lib.mkForce yes;
          CONFIG_PERF_EVENTS_INTEL_UNCORE = lib.mkForce yes;
          CONFIG_DRM_I915 = lib.mkForce yes;
          CONFIG_DRM_I915_GVT_KVMGT = lib.mkForce yes;
          CONFIG_INTEL_POWERCLAMP = lib.mkForce yes;
          CONFIG_X86_ACPI_CPUFREQ = lib.mkForce yes;

          # disable AMD-specific options
          CONFIG_AMD_NB = lib.mkForce no;
          CONFIG_X86_AMD_PLATFORM_DEVICE = lib.mkForce no;
          CONFIG_CPU_SUP_AMD = lib.mkForce no;
          CONFIG_DRM_AMDGPU = lib.mkForce no;
          CONFIG_AMD_IOMMU = lib.mkForce no;
          CONFIG_AMD_XGBE = lib.mkForce no;
          CONFIG_FB_RADEON = lib.mkForce no;
          CONFIG_DRM_RADEON = lib.mkForce no;
          CONFIG_X86_AMD_PSTATE = lib.mkForce no;
          CONFIG_KVM_AMD = lib.mkForce no;
          CONFIG_HW_RANDOM_AMD = lib.mkForce no;
          CONFIG_AGP_AMD64 = lib.mkForce no;
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
}
