{pkgs, ...}: let
  #Master: The master node handles all the administrative tasks for the cluster.
  # Node: A machine (physical or virtual) that runs workloads. Each node has a Kubernetes agent (kubelet) that manages the pods running on it.
  kubeMasterIP = "192.168.0.111"; # Master IP address
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;
in {
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    addons.dns.enable = true;

    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # Systemd services to give permissions to the kubelet secret pem  key
  systemd.services.kubelet-permissions = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      ExecStartPre = ''
        chown $(whoami):users /var/lib/kubernetes/secrets/cluster-admin-key.pem
        chmod 600 /var/lib/kubernetes/secrets/cluster-admin-key.pem
      '';
      User = "root";
      PermissionsStartOnly = true;
      RemainAfterExit = true;
    };
  };

  /*
  *  Apply your config (e.g. nixos-rebuild switch).
  *
  *  Link your kubeconfig to your home directory:
      $  mkdir ~/.kube
      $  ln -s /etc/kubernetes/cluster-admin.kubeconfig ~/.kube/config
  *
  *  Now, executing `kubectl cluster-info` should yield something like this:
  *
  *  Kubernetes master is running at https://10.1.1.2
  *  CoreDNS is running at https://10.1.1.2/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
  *
  *  To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

  */
}
