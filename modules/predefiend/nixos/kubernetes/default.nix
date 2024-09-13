{
  pkgs,
  unstable,
  user,
  lib,
  ...
}: let
  # Define key variables for your Kubernetes setup
  # The IP address of the Kubernetes master node, where the API server runs
  kubeMasterIP = "192.168.0.111";
  # The hostname of the Kubernetes master node, used for API server communications
  kubeMasterHostname = "api.kube";
  # The port where the Kubernetes API server listens (default 6443)
  kubeMasterAPIServerPort = 6443;
in {
  # Adds an entry to /etc/hosts for the Kubernetes master node
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # Installs required packages for Kubernetes
  environment.systemPackages = with unstable.${pkgs.system}; [
    kompose # Kompose helps convert Docker Compose files into Kubernetes resources
    kubectl # The Kubernetes command-line tool to interact with clusters
    kubernetes # Kubernetes itself
    minikube # A tool to run Kubernetes locally in a lightweight VM
    docker-machine-kvm2 # Docker driver for managing VMs via KVM2
  ];

  # Configures the Kubernetes service on this machine
  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname; # Master hostname used by the API server
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true; # Automatically generates certificates for secure communication

    # Configure the API server
    apiserver = {
      securePort = kubeMasterAPIServerPort; # The secure port for the API server (default 6443)
      advertiseAddress = kubeMasterIP; # IP address advertised to other nodes for connecting to the master
    };

    # Enable the DNS add-on (CoreDNS) for internal DNS resolution within the cluster
    addons.dns.enable = true;

    # Pass extra options to the Kubernetes `kubelet`
    kubelet.extraOpts = "--fail-swap-on=false"; # Kubernetes requires swap to be off, but this option ignores swap status
  };

  # Systemd service to fix permissions for the kubelet to access the cluster-admin key
  systemd.services."fix-kube-permissions" = {
    description = "Fix Kubernetes Permissions";

    # Dependencies: Make sure this service runs alongside the kubelet
    wants = ["kubelet.service"];
    wantedBy = ["multi-user.target"];
    requires = ["kubelet.service"];
    requiredBy = ["kubelet.service"];
    after = ["kubelet.service"];

    # The script that runs when the service starts
    script = ''
      chown ${user}:users /var/lib/kubernetes/secrets/cluster-admin-key.pem
      chmod 600 /var/lib/kubernetes/secrets/cluster-admin-key.pem
    '';

    # Systemd-specific configurations for the service
    serviceConfig = {
      ExecStart = let
        # This defines a script as a derivation, which is executed when the service starts
        fixKubePermissionsScript = pkgs.writeScriptBin "fix-kube-permissions" ''
          #!/usr/bin/env bash

          # Set ownership and permissions of the cluster admin key file
          chown ${user}:users /var/lib/kubernetes/secrets/cluster-admin-key.pem
          chmod 600 /var/lib/kubernetes/secrets/cluster-admin-key.pem
        '';
      in
        # Set this script as the default executable for the service
        lib.mkDefault "${fixKubePermissionsScript}";

      # The user as which the service runs (in this case, root)
      User = "root";

      # Restart the service if it fails
      Restart = "on-failure";

      # Only change permissions at the start of the service, then exit and leave them
      PermissionsStartOnly = true;

      # Keeps the service "active" after it finishes running
      RemainAfterExit = true;
    };
  };

  /*
  * After setting this configuration up, follow these steps:
  *
  * 1. Apply the configuration using nixos-rebuild:
  *    $ sudo nixos-rebuild switch
  *
  * 2. Link your kubeconfig to your home directory for easier access:
  *    $ mkdir ~/.kube              # Create the .kube directory if it doesn't exist
  *    $ ln -s /etc/kubernetes/cluster-admin.kubeconfig ~/.kube/config  # Link kubeconfig to your home directory
  *
  * 3. Now, you should be able to get cluster information using the following command:
  *    $ kubectl cluster-info
  *
  *    This should output something like:
  *    Kubernetes master is running at https://192.168.0.111
  *    CoreDNS is running at https://192.168.0.111/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
  *
  * 4. To further debug cluster issues, use the command:
  *    $ kubectl cluster-info dump
  *
  */
}
