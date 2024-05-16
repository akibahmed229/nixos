{ mkShell, hello, ... }:
mkShell {
  buildInputs = [ hello ];
  shellHook = ''
    echo "Hello, world!"
  '';
}
