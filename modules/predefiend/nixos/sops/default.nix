# Secrets management with SOPS and Nix

{ pkgs
, inputs
, user
, config
, ...
}:

{

  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/var/lib/sops-nix/secret_file";
  sops.age.generateKey = true;

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
