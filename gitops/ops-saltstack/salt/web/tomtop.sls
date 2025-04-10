include:
  - services.nginx.install
  - services.php.install
  - services.nodejs.install
  - services.logstash.install

tomtop_nginx_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://web/files/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx_service

{% for vhost in pillar['tomtop_vhost'] %}
/usr/local/nginx/conf/vhost/{{ vhost }}.conf:
  file.managed:
    - source: salt://web/files/{{ vhost }}.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        servername: {{ grains['ip_interfaces']['eth0'][0] }}
    - watch_in:
      - service: nginx_service
{% endfor %}

{% for project in pillar['tomtop_project'] %}
/data/www/{{ project  }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
{% endfor %}

/data/www/mnode:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - unless: test -d /data/www/mnode

/etc/logstash/conf.d/shipper-php.conf:
  file.managed:
    - source: salt://web/files/shipper-php.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - watch_in:
      - service: logstash_service