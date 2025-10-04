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
      environment.systemPackages = with pkgs; [
        kompose # Kompose helps convert Docker Compose files into Kubernetes resources
        kubectl # The Kubernetes command-line tool to interact with clusters
        kubernetes # Kubernetes itself
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
            addons.dns.enable = true;
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

      # -- Other Master-ONLY settings --
      networking.firewall.allowedTCPPorts = mkIf (cfg.role == "master") [
        cfg.kubeMasterAPIServerPort
        8888
      ];

      systemd.tmpfiles.rules = mkIf (cfg.role == "master") [
        "Z /var/lib/kubernetes/secrets/cluster-admin-key.pem 0600 ${user} users -"
      ];
    };
}
