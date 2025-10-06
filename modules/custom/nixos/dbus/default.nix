{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.dbus;
in {
  options.nm.dbus = {
    enable = mkEnableOption "Enable D-Bus an inter-process communication (IPC) for enabling communication between different applications and system components.";
  };

  /*
    D-Bus is an inter-process communication (IPC) mechanism widely used in Linux for enabling communication between different applications and system components.
  It functions as a message bus system, facilitating the exchange of messages between processes.
  */
  config = mkIf cfg.enable {
    services.dbus.enable = true;
  };
}
