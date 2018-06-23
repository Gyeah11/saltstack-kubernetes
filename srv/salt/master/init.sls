{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{%- set etcd01ip =  pillar['kubernetes']['etcd']['cluster']['etcd01']['ipaddr'] -%} 
{%- set etcd02ip =  pillar['kubernetes']['etcd']['cluster']['etcd02']['ipaddr'] -%} 
{%- set etcd03ip =  pillar['kubernetes']['etcd']['cluster']['etcd03']['ipaddr'] -%}
{%- set ipv4Range = pillar['kubernetes']['node']['networking']['flannel']['ipv4']['range'] -%}
{%- set etcdEndpoints = "https://{{ etcd01ip }}:2379,https://{{ etcd02ip }}:2379,https://{{ etcd03ip }}:2379" -%}

{# include:
  - master/etcd #}

/usr/bin/kube-apiserver:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-apiserver
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

/usr/bin/kube-controller-manager:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

/usr/bin/kube-scheduler:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-scheduler
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubectl
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755
{% if masterCount == 1 %}
/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://master/kube-apiserver.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% elif masterCount == 3 %}
/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://master/kube-apiserver-ha.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %}

/etc/systemd/system/kube-controller-manager.service:
  file.managed:
    - source: salt://master/kube-controller-manager.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kube-scheduler.service:
  file.managed:
    - source: salt://master/kube-scheduler.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/audit-policy.yaml:    
    file.managed:
    - source: salt://master/audit-policy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/encryption-config.yaml:    
    file.managed:
    - source: salt://master/encryption-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{%- set cniProvider = pillar['kubernetes']['node']['networking']['provider'] -%}
{% if cniProvider == "calico" %}

/opt/calico.yaml:
    file.managed:
    - source: salt://node/cni/calico/calico.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{% elif cniProvider == "flannel" %}

/opt/flannel.yaml:
    file.managed:
    - source: salt://node/cni/flannel/flannel.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

flannel-etcd-config:
  cmd.run:
    - runas: root
    - env:
      - ACTIVE_ETCD: https://{{ etcd01ip }}:2379
    - name: |
        curl --cacert /etc/kubernetes/ssl/ca.pem --key /etc/kubernetes/ssl/master-key.pem --cert /etc/kubernetes/ssl/master.pem --silent -X PUT -d "value={\"Network\":\"{{ ipv4Range }}\",\"Backend\":{\"Type\":\"vxlan\"}}" "https://{{ etcd01ip }}:2379/v2/keys/coreos.com/network/config?prevExist=false"

{% endif %}


kube-apiserver:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kube-apiserver.service
      #- /etc/kubernetes/ssl/apiserver.pem
kube-controller-manager:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kube-controller-manager.service
      #- /etc/kubernetes/ssl/apiserver.pem
kube-scheduler:
  service.running:
   - enable: True
   - reload: True
   - watch:
     - /etc/systemd/system/kube-scheduler.service
     #- /etc/kubernetes/ssl/apiserver.pem

include:
  - node.cri.docker
  - node.cri.rkt
  - kubernetes
