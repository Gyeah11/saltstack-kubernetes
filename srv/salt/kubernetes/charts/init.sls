{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.keycloak
{%- if charts.get('velero', {'enabled': False}).enabled %}
  - kubernetes.charts.velero
{%- endif -%}
{%- if charts.get('mailhog', {'enabled': False}).enabled %}
  - kubernetes.charts.mailhog
{%- endif -%}
{%- if charts.get('gitea', {'enabled': False}).enabled %}
  - kubernetes.charts.gitea
{%- endif -%}
{%- if charts.get('vistio', {'enabled': False}).enabled %}
  - kubernetes.charts.vistio
{%- endif -%}
{%- if charts.get('keycloak', {'enabled': False}).enabled and charts.get('keycloak_gatekeeper', {'enabled': False}).enabled %}
  - kubernetes.charts.keycloak-gatekeeper
{%- endif -%}
{%- if charts.get('proxyinjector', {'enabled': False}).enabled %}
  - kubernetes.charts.proxyinjector
{%- endif -%}
{%- if charts.get('harbor', {'enabled': False}).enabled %}
  - kubernetes.charts.harbor
{%- endif -%}
{%- if charts.get('concourse', {'enabled': False}).enabled %}
  - kubernetes.charts.concourse
{%- endif -%}
{%- if charts.get('argo', {'enabled': False}).enabled %}
  - kubernetes.charts.argo
{%- endif -%}
{%- if charts.get('argo_cd', {'enabled': False}).enabled %}
  - kubernetes.charts.argo-cd
{%- endif -%}
{%- if charts.get('argo_events', {'enabled': False}).enabled %}
  - kubernetes.charts.argo-events
{%- endif -%}
{%- if charts.get('spinnaker', {'enabled': False}).enabled %}
  - kubernetes.charts.spinnaker
{%- endif -%}
{%- if charts.get('openfaas', {'enabled': False}).enabled %}
  - kubernetes.charts.openfaas
{%- endif -%}
{%- if charts.get('falco', {'enabled': False}).enabled %}
  - kubernetes.charts.falco
{%- endif -%}
{%- if charts.get('nuclio', {'enabled': False}).enabled %}
  - kubernetes.charts.nuclio
{%- endif -%}
{%- if charts.get('jenkins', {'enabled': False}).enabled %}
  - kubernetes.charts.jenkins
{%- endif -%}
