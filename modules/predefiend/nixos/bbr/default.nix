{pkgs, ...}: {
  # Enable BBR congestion control
  boot = {
    kernelModules = [
      "tcp_bbr" # BBR congestion control algorithm for TCP that can achieve higher bandwidths and lower latencies.
    ];

    kernel = {
      sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
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
        "net.core.wmem_max" = 250 * 1024 * 1024;
        "net.core.rmem_max" = 250 * 1024 * 1024;
        "net.ipv4.tcp_rmem" = "4096 87380 262144000"; # 250 MiB max
        "net.ipv4.tcp_wmem" = "4096 87380 262144000"; # 250 MiB max
        # We do not need to adjust `net.ipv4.tcp_mem` (which limits the total
        # system-wide amount of memory to use for TCP, counted in pages) because
        # the kernel sets that to a high default of ~9% of system memory, see:
        # * https://github.com/torvalds/linux/blob/a1d21081a60dfb7fddf4a38b66d9cef603b317a9/net/ipv4/tcp.c#L4116
      };
    };
  };
}
