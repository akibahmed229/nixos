{
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

  home.file.".config/pipewire/pipewire-pulse.conf.d/10-adjustQuirkRules.conf".text = ''
    pulse.rules = [
        {
            matches = [
                {
                    # all keys must match the value. ! negates. ~ starts regex.
                    #client.name                = "Firefox"
                    #application.process.binary = "teams"
                    #application.name           = "~speech-dispatcher.*"
                }
            ]
            actions = {
                update-props = {
                    #node.latency = 512/48000
                }
                # Possible quirks:"
                #    force-s16-info                 forces sink and source info as S16 format
                #    remove-capture-dont-move       removes the capture DONT_MOVE flag
                #    block-source-volume            blocks updates to source volume
                #    block-sink-volume              blocks updates to sink volume
                #quirks = [ ]
            }
        }
        {
            # skype does not want to use devices that don't have an S16 sample format.
            matches = [
                 { application.process.binary = "teams" }
                 { application.process.binary = "teams-insiders" }
                 { application.process.binary = "skypeforlinux" }
            ]
            actions = { quirks = [ force-s16-info ] }
        }
        {
            # firefox marks the capture streams as don't move and then they
            # can't be moved with pavucontrol or other tools.
            matches = [ { application.process.binary = "firefox" } ]
            actions = { quirks = [ remove-capture-dont-move ] }
        }
        {
            # speech dispatcher asks for too small latency and then underruns.
            matches = [ { application.name = "~speech-dispatcher.*" } ]
            actions = {
                update-props = {
                    pulse.min.req          = 512/48000      # 10.6ms
                    pulse.min.quantum      = 512/48000      # 10.6ms
                    pulse.idle.timeout     = 5              # pause after 5 seconds of underrun
                }
            }
        }
       {
            # prevent all sources matching "Chromium" from messing with the volume
            matches = [ { application.name = "~Chromium.*" } ]
            actions = { quirks = [ block-source-volume ] }

        }
        {
            matches = [ { application.process.binary = "~vesktop.*" } ]
            actions = { quirks = [ block-source-volume ] }
        }
    ]
  '';
}
