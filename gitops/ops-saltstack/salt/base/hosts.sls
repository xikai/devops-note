{% if grains['env']  == 'uat' %}
/etc/hosts:
  file.managed:
    - source: salt://base/files/uat_hosts
{% endif %}