include:
  - services.nginx.install
  - services.logstash.install
  - services.tomcat.install
  - services.filebeat.install 

{% if grains['env']  == 'prod' %}
nginx_ilb_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://ilb/files/vhost_prod/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx_service

{% for vhost in pillar['ilb_vhost'] %}
/usr/local/nginx/conf/vhost/{{ vhost }}.conf:
  file.managed:
    - source: salt://ilb/files/vhost_prod/{{ vhost }}.conf
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
nginx_ilb_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://ilb/files/vhost_uat/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx_service

{% for vhost in pillar['ilb_vhost'] %}
/usr/local/nginx/conf/vhost/{{ vhost }}.conf:
  file.managed:
    - source: salt://ilb/files/vhost_uat/{{ vhost }}.conf
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

#/etc/logstash/conf.d/shipper-ilb.conf:
#  file.managed:
#    - source: salt://ilb/files/shipper-ilb.conf
#    - user: root
#    - group: root
#    - mode: 644
#    - template: jinja
#    - watch_in:
#      - service: logstash_service

######################################################################
#{% for project in pillar['ilb_project'] %}
#tomcat-{{ project }}:
#  cmd.run:
#    - cwd: /usr/local/src
#    - name: cp -r apache-tomcat-8.0.26 /usr/local/tomcat-{{ project }}
#    - unless: test -d /usr/local/tomcat-{{ project }}
#    - require:
#      - cmd: tomcat_source
#
#/usr/local/tomcat-{{ project }}/conf/server.xml:
#  file.managed:
#    - source: salt://ilb/files/server-{{ project }}.xml
#    - user: root
#    - mode: 644
#
#/usr/local/tomcat-{{ project }}/bin/setenv.sh:
#  file.managed:
#    - source: salt://ilb/files/setenv-{{ project }}.sh
#    - user: root
#    - mode: 755
#    - template: jinja
#
#/data/www/{{ project }}:
#  file.directory:
#    - user: root
#    - group: root
#    - mode: 755
#    - makedirs: True
#
#/data/war:
#  file.directory:
#    - user: root
#    - group: root
#    - mode: 755
#    - makedirs: True
#
#/data/logs/{{ project }}:
#  file.directory:
#    - user: root
#    - group: root
#    - mode: 755
#    - makedirs: True
#
#/usr/local/tomcat-{{ project }}/webapps/ROOT:
#  file.symlink:
#  - target: /data/www/{{ project }}
#
#/usr/local/tomcat-{{ project }}/logs:
#  file.symlink:
#  - target: /data/logs/{{ project }}
#
#tomcat-{{ project }}_service:
#  file.managed:
#    - name: /usr/lib/systemd/system/tomcat-{{ project }}.service
#    - source: salt://ilb/files/tomcat-{{ project }}.service
#    - user: root
#    - mode: 755
#    - template: jinja
#    - defaults:
#        project: {{ project }}
#  service.running:
#    - name: tomcat-{{ project }}
#    - enable: True
#    - restart: True
#    - watch:
#      - file: /usr/local/tomcat-{{ project }}/conf/server.xml
#      - file: /usr/local/tomcat-{{ project }}/bin/setenv.sh
#{% endfor %}
#
#/etc/filebeat/filebeat.yml:
#  file.managed:
#    - source: salt://ilb/files/filebeat.yml
#    - user: root
#    - group: root
#    - mode: 644
#    - template: jinja
#    - watch_in:
#      - service: filebeat_service#