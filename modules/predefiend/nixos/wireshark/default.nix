{pkgs, ...}: {
  /*
    Wireshark is a free, open-source network protocol analyzer that captures and displays network traffic in real-time,
  allowing users to inspect data at the packet level to diagnose network problems, analyze application behavior, and investigate security issues.
  */
  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
}
