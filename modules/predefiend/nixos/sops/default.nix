# configuration.nix

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

  sops.secrets."myservice/my_subdir/my_secret" = {
    owner = "${user}";
    path = "/home/${user}/.config/sops/secrets/myservice/my_subdir/my_secret";
  };

  #systemd.services."sometestservice" = {
  #  script = ''
  #    echo "
  #    Hey bro! I'm a service, and imma send this secure password:
  #    $(cat ${config.sops.secrets."myservice/my_subdir/my_secret".path})
  #    located in:
  #    ${config.sops.secrets."myservice/my_subdir/my_secret".path}
  #    to database and hack the mainframe
  #    " > /var/lib/sometestservice/testfile
  #  '';
  #  serviceConfig = {
  #    User = "sometestservice";
  #    WorkingDirectory = "/var/lib/sometestservice";
  #  };
  #};

  #users.users.sometestservice = {
  #  home = "/var/lib/sometestservice";
  #  createHome = true;
  #  isSystemUser = true;
  #  group = "sometestservice";
  #};
  #users.groups.sometestservice = { };

}
