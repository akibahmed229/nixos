{user, ...}: {
  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "enp4s0";
      WIFI_IFACE = "wlp0s20f0u4";
      SSID = "${user}'s AP";
      PASSPHRASE = "12345678";
    };
  };
}
