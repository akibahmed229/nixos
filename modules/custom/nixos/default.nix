{
  mainUser = import ./user;
  enableBoot = import ./grub;
  enableAudio = import ./audio;
  enableKvm = import ./kvm;

  default.imports =
    [ (import ./user) ] ++
    [ (import ./grub) ] ++
    [ (import ./audio) ] ++
    [ (import ./kvm) ];
}
