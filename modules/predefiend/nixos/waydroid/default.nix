{pkgs, ...}: {
  /*
    Waydroid is an open-source software project that allows you to run Android applications on Linux systems
  by booting a full Android environment within a containerized environment using Linux namespaces.
  */
  virtualisation.waydroid.enable = true;
}
