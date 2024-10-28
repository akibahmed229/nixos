{
  pkgs,
  user,
  lib,
  inputs,
  ...
}: let
  secretsInput = builtins.toString inputs.secrets;
  email = lib.strings.trim (builtins.readFile "${secretsInput}/github/email.txt");
  username = lib.strings.trim (builtins.readFile "${secretsInput}/github/username.txt");
in
  lib.mkIf (user == "akib") {
    programs.git = {
      enable = true;
      package = pkgs.git;
      userName = username;
      extraConfig = {
        user = {
          userEmail = email;
          signingkey = email;
        };
        commit = {
          gpgSign = true;
        };
      };
    };
  }
