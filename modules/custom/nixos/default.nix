# Reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # Import the modules from the files in this directory
  mainUser = import ./user;
  enableBoot = import ./grub;
  enableAudio = import ./audio;
  enableKvm = import ./kvm;

  # by default, import all the modules
  default.imports =
    [ (import ./user) ] ++
    [ (import ./grub) ] ++
    [ (import ./audio) ] ++
    [ (import ./kvm) ];
}
