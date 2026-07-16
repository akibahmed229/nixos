# virt home-manager configuration
{
  pkgs,
  lib,
  user,
  inputs,
  config,
  ...
}: {
  hm = lib.mkMerge [
    {
      firefox = {
        en = true;
        user = user;
      };
      nvim.en = true;
      thunar.en = true;
    }

    (lib.mkIf (user == "akib") {
      git.en = true;
      ssh.en = true;
      sops = let
        secretsInput = toString inputs.secrets;
        homeDirectory = config.home.homeDirectory;
      in {
        en = true;
        defaultSopsFile = "${secretsInput}/secrets/home-manager.yaml";
        secrets = {
          "github/sshKey".path = "${homeDirectory}/.ssh/id_ed25519_github";
          "gitlab/sshKey".path = "${homeDirectory}/.ssh/id_ed25519_gitlab";
          "github/username".path = "${homeDirectory}/.config/git/username";
          "github/email".path = "${homeDirectory}/.config/git/email";
        };
        # The dynamic Git template
        templates = {
          "git-user.conf" = {
            mode = "0400";
            content = ''
              [user]
                name = ${config.sops.placeholder."github/username"}
                email = ${config.sops.placeholder."github/email"}
                signingkey = ${config.sops.placeholder."github/email"}
            '';
          };
        };
      };
    })
  ];

  home.packages = with pkgs; [
    # 1. Screenshot & Screen Tools
    xclip
    klipper

    # 2. Utility
    udiskie
  ];

  home.file.".xprofile".text = ''
    # Start dbus if not running
    if ! pgrep -x dbus-daemon > /dev/null; then
      eval $(dbus-launch --exit-with-session)
    fi

    # Start spice agent for clipboard & dynamic resize
    ${pkgs.spice-vdagent}/bin/spice-vdagent &
  '';

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
