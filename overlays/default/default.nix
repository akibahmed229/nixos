/*
DESCRIPTION: Global package overrides and patches for nixpkgs.

USE CASE:
Use this file to fix broken packages, apply patches, or override
attributes globally across your entire system/home configuration.
*/
{inputs, ...}:
# 'final' represents the nixpkgs state AFTER all overlays are applied.
# 'prev' represents the nixpkgs state BEFORE this specific overlay.
final: prev: {
  # ===========================================================================
  # SECTION 1: OVERRIDING ATTRIBUTES (overrideAttrs)
  # Use this for simple changes like disabling tests, changing versions,
  # or adding build inputs to a standard package.
  # ===========================================================================

  # Example: Disabling tests for a package that is failing its check phase
  # some-package = prev.some-package.overrideAttrs (oldAttrs: {
  #   doCheck = false;
  # });

  # ===========================================================================
  # SECTION 2: SCOPED OVERRIDES (Python, Lua, etc.)
  # Languages with their own package managers inside Nix need 'overrideScope'.
  # ===========================================================================

  python3Packages = prev.python3Packages.overrideScope (pythonFinal: pythonPrev: {
    # CURRENT FIX: picosvg
    # We disable tests because they are currently broken upstream/in nixpkgs
    picosvg = pythonPrev.picosvg.overridePythonAttrs (old: {
      doCheck = false;
    });

    # Example: Adding a missing dependency to a python package
    # requests = pythonPrev.requests.overridePythonAttrs (old: {
    #   propagatedBuildInputs = old.propagatedBuildInputs ++ [ pythonPrev.setuptools ];
    # });
  });

  # ===========================================================================
  # SECTION 3: ADDING NEW PACKAGES
  # You can define entirely new packages here or pull them from 'inputs'.
  # ===========================================================================

  # Example: Pulling a package from a specific flake input
  # custom-package = inputs.some-flake.packages.${prev.system}.default;

  # ===========================================================================
  # EDGE CASE & BEST PRACTICES NOTES:
  # ===========================================================================
  /*
  1. INFINITE RECURSION:
     Always use 'prev.package' when overriding 'package'.
     If you use 'final.package' inside the definition of 'package',
     Nix will loop forever trying to resolve it.

  2. OVERRIDE vs OVERRIDEATTRS:
     - Use 'overrideAttrs' for the derivation (src, buildInputs, patches).
     - Use 'override' for the function arguments (enableGnome = true).

  3. VERSION BUMPING:
     If you change the 'src', remember to update the 'hash' or 'sha256',
     otherwise Nix will complain about a hash mismatch.
  */
}
