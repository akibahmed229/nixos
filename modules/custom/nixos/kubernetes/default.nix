# modules/kubernetes.nix
{
  pkgs,
  user,
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

  # Set up your kubectl command to point to the cluster's configuration:


      ```bash

        mkdir -p ~/.kube

        sudo ln -s /etc/kubernetes/cluster-admin.kubeconfig ~/.kube/config

        sudo chown -R $(whoami) ~/.kube

      ```

  # Check the status of your nodes. You should see both your master and worker, and they should both be in the Ready state after a minute or two.


      `kubectl get nodes`


  # Expected Output:


    ```bash

      NAME      STATUS   ROLES           AGE   VERSION

      master    Ready    control-plane   5m    v1.28.x

      worker    Ready    <none>          2m    v1.28.x

    ```

  */

  # --- 2. Define the configuration based on the role ---
  config = let
    cfg = config.nm.k8s;
  in
    mkIf cfg.enable {
      # -- Common settings for ALL nodes (master and worker) --
      networking.extraHosts = "${cfg.kubeMasterIP} ${cfg.kubeMasterHostname}";
      environment.systemPackages = with pkgs; [kubectl];

      # --- UNIFIED services.kubernetes block ---
      services.kubernetes = let
        api = "https://${cfg.kubeMasterHostname}:${toString cfg.kubeMasterAPIServerPort}";
      in
        lib.mkMerge [
          # 1. Common settings for ALL nodes
          {
            apiserverAddress = api;
            easyCerts = true;
            masterAddress = cfg.kubeMasterHostname;
            # needed if you use swap
            kubelet.extraOpts = "--fail-swap-on=false";
            # use coredns
            addons.dns.enable = true;
          }

          # 2. Master-ONLY settings (conditionally included)
          (lib.mkIf (cfg.role == "master") {
            roles = ["master" "node"];
            apiserver = {
              securePort = cfg.kubeMasterAPIServerPort;
              advertiseAddress = cfg.kubeMasterIP;
            };
            proxy.enable = true;
          })

          # 3. Worker-ONLY settings (conditionally included)
          (lib.mkIf (cfg.role == "worker") {
            roles = ["node"];
            masterAddress = cfg.kubeMasterHostname;

            # point kubelet and other services to kube-apiserver
            kubelet.kubeconfig.server = api;
          })
        ];

      # -- Other Master-ONLY settings --
      networking.firewall.allowedTCPPorts = mkIf (cfg.role == "master") [
        cfg.kubeMasterAPIServerPort
      ];

      systemd.tmpfiles.rules = mkIf (cfg.role == "master") [
        "Z /var/lib/kubernetes/secrets/cluster-admin-key.pem 0600 ${user} users -"
      ];
    };
}
