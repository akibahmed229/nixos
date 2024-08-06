lib: {
  mkNixOSSystem = import ./mkNixOSSystem;
  mkImport = import ./mkImport {inherit lib;};
}
