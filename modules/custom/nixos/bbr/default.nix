# Enables BBR congestion control and tunes kernel parameters for high-speed,
# high-latency connections based on common recommendations.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.bbr;

  # Calculate max buffer size in bytes from the user-defined MiB value
  maxBufferSizeMiB = cfg.maxBufferSizeMiB;
  maxSizeBytes = maxBufferSizeMiB * 1024 * 1024;
  maxSizeSysctlString = toString maxSizeBytes;

  # Min (4 KiB) and default (85 KiB) values for TCP R/W memory, combined with the max size.
  # The max buffer size is slightly larger than 250 MiB (262144000 bytes)
  tcpMemValue = "4096 87380 ${maxSizeSysctlString}";
in {
  # --- 1. Define Options ---
  options.nm.bbr = {
    enable = mkEnableOption "Enable TCP BBR congestion control and optimized network buffer settings";

    maxBufferSizeMiB = mkOption {
      type = types.int;
      default = 250;
      description = ''
        The maximum size (in MiB) to set for TCP read/write buffers (net.core.rmem_max,
        net.core.wmem_max) and the maximum threshold for net.ipv4.tcp_rmem/tcp_wmem.
        The default (250 MiB) is calculated for a 1 Gbit/s connection with 200ms latency
        to account for BBR's recommended 4x Bandwidth-Delay Product (BDP).
      '';
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Load the TCP BBR kernel module
    boot.kernelModules = [
      "tcp_bbr"
    ];

    # 2.2 Configure sysctl parameters
    boot.kernel.sysctl = {
      # Enable BBR as the default TCP congestion control algorithm
      "net.ipv4.tcp_congestion_control" = "bbr";

      # Use Fair Queue (FQ) as the default queue discipline for better performance
      "net.core.default_qdisc" = "fq"; # see https://news.ycombinator.com/item?id=14814530

      # Increase TCP window sizes for high-bandwidth WAN connections, assuming
      # 1 GBit/s Internet over 200ms latency as worst case.
      #
      # Choice of value:
      #     BPP         = 1000 MBit/s / 8 Bit/Byte * 0.2 s = 25 MB
      #     Buffer size = BPP * 4 (for BBR)                 = 100 MB
      # Explanation:
      # * According to http://ce.sc.edu/cyberinfra/workshops/Material/NTP/Lab%208.pdf
      #   and other sources, "Linux assumes that half of the send/receive TCP buffers
      #   are used for internal structures", so the "administrator must configure
      #   the buffer size equals to twice" (2x) the BPP.
      # * The article's section 1.3 explains that with moderate to high packet loss
      #   while using BBR congestion control, the factor to choose is 4x.
      #
      # Note that the `tcp` options override the `core` options unless `SO_RCVBUF`
      # is set manually, see:
      # * https://stackoverflow.com/questions/31546835/tcp-receiving-window-size-higher-than-net-core-rmem-max
      # * https://bugzilla.kernel.org/show_bug.cgi?id=209327
      # There is an unanswered question in there about what happens if the `core`
      # option is larger than the `tcp` option; to avoid uncertainty, we set them
      # equally.

      # Set core kernel memory limits for read/write buffers
      "net.core.wmem_max" = maxSizeBytes;
      "net.core.rmem_max" = maxSizeBytes;

      # Set TCP-specific memory limits (min, default, max)
      "net.ipv4.tcp_rmem" = tcpMemValue;
      "net.ipv4.tcp_wmem" = tcpMemValue;

      # We do not need to adjust `net.ipv4.tcp_mem` (which limits the total
      # system-wide amount of memory to use for TCP, counted in pages) because
      # the kernel sets that to a high default of ~9% of system memory, see:
      # * https://github.com/torvalds/linux/blob/a1d21081a60dfb7fddf4a38b66d9cef603b317a9/net/ipv4/tcp.c#L4116
    };
  };
}
