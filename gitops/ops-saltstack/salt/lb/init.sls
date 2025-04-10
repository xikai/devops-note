include:
  - services.lb.install
  - services.logstash.install

{% if grains['env']  == 'prod' %}
nginx_lb_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://lb/files/vhost_prod/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx_service

{% for vhost in pillar['lb_vhost'] %}
/usr/local/nginx/conf/vhost/{{ vhost }}.conf:
  file.managed:
    - source: salt://lb/files/vhost_prod/{{ vhost }}.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults: 
        servername: {{ grains['ip_interfaces']['eth0'][0] }}
    - watch_in:
      - service: nginx_service
{% endfor %}
{% endif %}

{% if grains['env']  == 'uat' %}
nginx_lb_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://lb/files/vhost_uat/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx_service

{% for vhost in pillar['lb_vhost'] %}
/usr/local/nginx/conf/vhost/{{ vhost }}.conf:
  file.managed:
    - source: salt://lb/files/vhost_uat/{{ vhost }}.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        servername: {{ grains['ip_interfaces']['eth0'][0] }}
    - watch_in:
      - service: nginx_service
{% endfor %}
{% endif %}


{% for pem in pillar['ssl_pem'] %}
/usr/local/nginx/conf/{{ pem }}:
  file.managed:
    - source: salt://lb/files/{{ pem }}
    - user: root
    - group: root
    - mode: 644
{% endfor %}

{% for key in pillar['ssl_key'] %}
/usr/local/nginx/conf/{{ key }}:
  file.managed:
    - source: salt://lb/files/{{ key }}
    - user: root
    - group: root 
    - mode: 644
{% endfor %}


{% for project in pillar['static_project'] %}
/data/www/{{ project  }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
{% endfor %}

/data/nginx/proxy_temp:
  file.directory:
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

/data/nginx/proxy_cache:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

#/etc/logstash/conf.d/shipper-lb.conf:
#  file.managed:
#    - source: salt://lb/files/shipper-lb.conf
#    - user: root
#    - group: root
#    - mode: 644
#    - template: jinja
#    - watch_in:
#      - service: logstash_service