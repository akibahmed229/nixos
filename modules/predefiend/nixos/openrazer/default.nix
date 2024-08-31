{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    polychromatic
  ];

  # Enable OpenRazer
  hardware.openrazer.enable = true;

  /*
    * In order to run the openrazer-daemon service, your user needs to be part of the openrazer group.

        hardware.openrazer.users = ["<name>?"];


  # some other tools for keyboard and mouse control

  * CORSAIR USERS
      https://github.com/ckb-next/ckb-next/wiki/Supported-Hardware

  * SOLAAR/LOGITECH
      https://github.com/pwr-Solaar/Solaar
      https://flathub.org/apps/io.github.pwr_solaar.solaar

  * OPENRAZER & POLYCHROMATIC & RAZERGENIE
      https://openrazer.github.io/
      https://polychromatic.app/
      https://github.com/z3ntu/RazerGenie

  * ERUPTION
      https://github.com/eruption-project/eruption

  * PIPER/STEELSERIES/LOGITECH/ASUS/GLORIOUS
      https://github.com/libratbag/piper?tab=readme-ov-file
      https://github.com/libratbag/libratbag/tree/master/data/devices
      https://flathub.org/apps/org.freedesktop.Piper


  * you can check your mouse pooling rate with

      sudo nix-shell -p evhz.out --run 'evhz ...'
  */
}
