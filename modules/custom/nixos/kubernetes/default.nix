# modules/kubernetes.nix
{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  # --- 1. Define all options in one place ---
  options.nm.k8s = {
    enable = mkEnableOption "Enable Kubernetes cluster member";

    role = mkOption {
      type = types.enum ["master" "worker"];
      description = "The role of this node in the Kubernetes cluster.";
    };

    defaultUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The user name for the kubernetes admin required for fixed permissions";
    };

    kubeMasterIP = mkOption {
      type = types.str;
      description = "The IP address of the Kubernetes master node.";
    };

    kubeMasterHostname = mkOption {
      type = types.str;
      default = "api.kube";
      description = "The hostname of the Kubernetes master node.";
    };

    kubeMasterAPIServerPort = mkOption {
      type = types.int;
      default = 6443;
      description = "The port for the Kubernetes API server.";
    };
  };

  /*
  ####################### For Master ############################################

  # Set up your kubectl command to point to the cluster's configuration:
      ```bash
        mkdir -p ~/.kube
        sudo ln -s /etc/kubernetes/cluster-admin.kubeconfig ~/.kube/config
        sudo chown -R $(whoami) ~/.kube

      ```

  ####################### For Worker ############################################

  # on the master, grab the apitoken
      - `cat /var/lib/kubernetes/secrets/apitoken.secret`

  # on the node, join the node with
      - `echo TOKEN | nixos-kubernetes-node-join`


  ####################### For Join Cluster ############################################

  # Check the status of your nodes. You should see both your master and worker, and they should both be in the Ready state after a minute or two.
     - `kubectl get nodes`


  # Expected Output:
    ```bash
      NAME      STATUS   ROLES           AGE   VERSION
      desktop    Ready    control-plane   5m    v1.28.x
      virt    Ready    <none>          2m    v1.28.x

    ```

  */

  # --- 2. Define the configuration based on the role ---
  config = let
    cfg = config.nm.k8s;
  in
    mkIf cfg.enable {
      # -- Common settings for ALL nodes (master and worker) --
      networking.extraHosts = "${cfg.kubeMasterIP} ${cfg.kubeMasterHostname}";
      environment.systemPackages = with pkgs;
        [
          kubernetes # Kubernetes itself
        ]
        ++ lib.optionals (cfg.role == "master") [
          kompose # Kompose helps convert Docker Compose files into Kubernetes resources
          kubectl # The Kubernetes command-line tool to interact with clusters
          kubernetes-helm # The Kubernetes package manager
        ];

      # --- UNIFIED services.kubernetes block ---
      services.kubernetes = let
        api = "https://${cfg.kubeMasterHostname}:${toString cfg.kubeMasterAPIServerPort}";
      in
        lib.mkMerge [
          # 1. Common settings
          {
            apiserverAddress = api;
            easyCerts = true;
            masterAddress = cfg.kubeMasterHostname;
            # use coredns
            addons.dns = {
              enable = true;
              # Fix the CoreDNS image details for AArch64 builds
              coredns = lib.mkIf pkgs.stdenv.isAarch64 {
                # Use the standard Kubernetes CoreDNS tag
                finalImageTag = "v1.11.1";
                imageDigest = "sha256:1eeb4c7316bacb1d4c8ead65571cd92dd21e27359f0d4917f1a5822a73b75db1";
                imageName = "coredns/coredns";
                # NOTE: This SHA256 is the Nix content hash for the layers of the v1.11.1 AArch64 image.
                # It is crucial for reproducible builds.
                sha256 = "190m0j32x617a2w3x8y7ygl7w6b5q93h8d0y5b045h0g5j0y1d5d";
              };
            };
          }

          # 2. Master-ONLY settings (conditionally included)
          (lib.mkIf (cfg.role == "master") {
            roles = ["master" "node"];
            apiserver = {
              securePort = cfg.kubeMasterAPIServerPort;
              advertiseAddress = cfg.kubeMasterIP;

              # ADD the custom hostname to the API server SANs
              extraSANs = [
                cfg.kubeMasterHostname # 'api.kube'
                cfg.kubeMasterIP # '192.168.0.111'
              ];
            };
            # needed if you use swap
            kubelet.extraOpts = "--fail-swap-on=false";
            proxy.enable = true;
          })

          # 3. Worker-ONLY settings (conditionally included)
          (lib.mkIf (cfg.role == "worker") {
            roles = ["node"];
            # point kubelet and other services to kube-apiserver
            kubelet.kubeconfig.server = api;
            # needed if you use swap
            kubelet.extraOpts = "--fail-swap-on=false";
          })
        ];

      services.etcd.enable = mkIf (cfg.role == "master") true;

      systemd.services.etcd.environment = lib.mkIf pkgs.stdenv.isAarch64 {
        ETCD_UNSUPPORTED_ARCH = "arm64";
      };

      # -- Other Master-ONLY settings --
      networking.firewall.allowedTCPPorts = mkIf (cfg.role == "master") [
        cfg.kubeMasterAPIServerPort
        8888
      ];

      # Part 1: The "Fixer" Service
      # This is a simple, one-shot service that corrects the file permissions.
      systemd.services.fix-kube-permissions = mkIf (cfg.role == "master" && cfg.defaultUser != null) {
        description = "Correct permissions for the K8s cluster-admin key";
        # This service doesn't start on its own; it's triggered by the path unit.
        serviceConfig = {
          Type = "oneshot";
          User = "root"; # <-- Must run as root to chown/chmod system files.
        };
        # The script to execute when triggered.
        script = ''
          echo "Correcting permissions for /var/lib/kubernetes/secrets/cluster-admin-key.pem"
          chown ${cfg.defaultUser}:users /var/lib/kubernetes/secrets/cluster-admin-key.pem
          chmod 600 /var/lib/kubernetes/secrets/cluster-admin-key.pem
        '';
      };

      # Part 2: The "Watcher" Path Unit
      # This unit monitors the file and triggers the service above when it changes.
      systemd.paths.fix-kube-permissions = mkIf (cfg.role == "master" && cfg.defaultUser != null) {
        description = "Watch for changes to the K8s cluster-admin key permissions";
        wantedBy = ["multi-user.target"]; # Enable this watcher on boot.
        pathConfig = {
          # Trigger when the file is written to or its attributes change.
          PathModified = "/var/lib/kubernetes/secrets/cluster-admin-key.pem";
          # When triggered, start the following service unit.
          Unit = "fix-kube-permissions.service";
        };
      };
    };
}
