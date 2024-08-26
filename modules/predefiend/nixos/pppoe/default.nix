/*
* When the system starts up pppd-edpnet.service, you should now see a ppp0 interface
  with an IP address (note: if you already have a default gateway set on the system
  when the PPPoE seesion comes online, it will not replace the degault gateway).
*/
{_}: {
  # setup pppoe session
  services.pppd = {
    enable = true;
    peers = {
      edpnet = {
        # Autostart the PPPoE session on boot
        autostart = true;
        enable = true;
        config = ''
          plugin rp-pppoe.so wan

          # pppd supports multiple ways of entering credentials,
          # this is just 1 way
          name "random"
          password "random"

          persist
          maxfail 0
          holdoff 5

          noipdefault
          defaultroute
        '';
      };
    };
  };
}
