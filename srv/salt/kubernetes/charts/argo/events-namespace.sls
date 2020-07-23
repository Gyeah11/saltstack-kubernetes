argo-events-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/events-namespace.yaml
    - source: salt://{{ tpldir }}/files/events-namespace.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo/events-namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/events-namespace.yaml