{config, ...}: {
  /*
  # systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service

  * How PipeWire works (in general)
      - PipeWire = modern replacement for PulseAudio + JACK.
  * Handles:
      - Audio routing (apps ↔ devices ↔ virtual sinks/sources).

  * Video routing (screen sharing, cameras).
      - Session management (through wireplumber).
      - pipewire-pulse = compatibility shim so PulseAudio apps still work.
      - WirePlumber = policy/session manager (decides which device is default, applies routing logic).
  */

  /*
  * Why the problem occurred
    - Some applications (Discord, Chromium, Teams, Firefox, etc.) try to control source/sink volume themselves.
    - PipeWire exposes a PulseAudio compatibility layer (pipewire-pulse) that honors these client requests by default.
    - Result: when these apps change the source volume, your mic/input levels keep resetting unexpectedly.

  * How the fix works
    - PipeWire allows quirk rules (overrides) via config files.
    - By adding a rule under pipewire-pulse.conf.d/, you tell PipeWire:
    - “For this application, ignore its volume requests and enforce my settings instead.”

  * Example:
      '''
      { application.process.binary = "Discord" }
      actions = { quirks = [ block-source-volume ]; }
      '''
  */

  home.file = {
    ".config/pipewire/pipewire-pulse.conf.d/10-adjustQuirkRules.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink ./10-adjustQuirkRules.conf; # tells wireplumber to ignore cameras
      recursive = true;
    };
  };
}
