kubernetes:
  version: v1.10.4
  domain: cluster.local
  etcd:
    count: 3
    cluster:
      etcd01:
        hostname: etcd01
        ipaddr: 172.16.4.51
      etcd02:
        hostname: etcd02
        ipaddr: 172.16.4.52
      etcd03:
        hostname: etcd03
        ipaddr: 172.16.4.53
    version: v3.2.22
  master:
#    count: 1
#    hostname: master.domain.tld
#    ipaddr: 10.240.0.10
    count: 3
    cluster:
      node01:
        hostname: master01
        ipaddr: 172.16.4.101
      node02:
        hostname: master02
        ipaddr: 172.16.4.102
      node03:
        hostname: master03
        ipaddr: 172.16.4.103
    encryption-key: 'w3RNESCMG+o3GCHTUcrQUUdq6CFV72q/Zik9LAO8uEc='
  node:
    runtime:
      provider: docker
      docker:
        version: 17.03.2-ce
        data-dir: /var/lib/docker
      rkt:
        version: 1.29.0
    networking:
      cni-version: v0.7.1
      provider: calico
      calico:
        version: v3.1.3
        cni-version: v3.1.3
        calicoctl-version: v3.1.3
        controller-version: 3.1-release
        as-number: 64512
        token: hu0daeHais3aCHANGEMEhu0daeHais3a
        ipv4:
          range: 192.168.0.0/16
          nat: true
          ip-in-ip: true
        ipv6:
          enable: false
          nat: true
          interface: ens18
          range: fd80:24e2:f998:72d6::/64
  global:
    proxy:
      ipaddr: 172.16.4.251
      port: 8888
    vpnIP-range: 172.16.4.0/24
    pod-network: 10.2.0.0/16
    kubernetes-service-ip: 10.3.0.1
    service-ip-range: 10.3.0.0/24
    clusterDNS: 10.3.0.10
    helm-version: v2.8.2
    dashboard-version: v1.8.3
    admin-token: Haim8kay1rarCHANGEMEHaim8kay1rar
    kubelet-token: ahT1eipae1wiCHANGEMEahT1eipae1wi
    bootstrap-token: c6925295f34652d872042f0d28170ca3
tinyproxy:
  MaxClients: 200
  MinSpareServers: 10
  MaxSpareServers: 40
  StartServers: 20
  Allow:
    - 127.0.0.1
    - 192.168.0.0/16
    - 172.16.0.0/12
    - 10.0.0.0/8
keepalived:
  global_defs:
    router_id: LVS_DEVEL
  vrrp_instance:
    VI_1:
      state: MASTER
      interface: wg0
      virtual_router_id: 51
      priority: 100
      advert_int: 1
      authentication:
        auth_type: PASS
        auth_pass: 1111
      virtual_ipaddress:
        - 172.16.4.253
        - 172.16.4.254
  virtual_server:
    0.0.0.0 6443:
      delay_loop: 6
      lb_algo: rr
      lb_kind: NAT
      nat_mask: 255.255.255.0
      persistence_timeout: 50
      protocol: TCP
      real_server:
        172.16.4.101 6443:
          weight: 1
        172.16.4.102 6443:
          weight: 2
        172.16.4.103 6443:
          weight: 3
haproxy:
  enabled: true
  overwrite: True
  global:
    ssl-default-bind-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384"
    ssl-default-bind-options: "no-sslv3 no-tlsv10 no-tlsv11"
  user: haproxy
  group: haproxy
  chroot:
    enable: true
    path: /var/lib/haproxy
  daemon: true
  frontends:
    kubernetes-master:
      bind: "*:6443"
      mode: tcp
      default_backend: kube-apiserver
  backends:
    kube-apiserver:
      mode: tcp
      balance: source
      sticktable: "type binary len 32 size 30k expire 30m"
      servers:
        master01:
          host: 172.16.4.101
          port: 6443
        master02:
          host: 172.16.4.102
          port: 6443
        master03:
          host: 172.16.4.103
          port: 6443
