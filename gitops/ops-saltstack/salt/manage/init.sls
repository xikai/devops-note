include:
  - services.tomcat.install
  - services.filebeat.install

{% for project in pillar['manage_project'] %}
tomcat-{{ project }}:
  cmd.run:
    - cwd: /usr/local/src
    - name: cp -r apache-tomcat-8.0.26 /usr/local/tomcat-{{ project }}
    - unless: test -d /usr/local/tomcat-{{ project }}
    - require:
      - cmd: tomcat_source

/usr/local/tomcat-{{ project }}/conf/server.xml:
  file.managed:
    - source: salt://manage/files/server-{{ project }}.xml
    - user: root
    - mode: 644

/usr/local/tomcat-{{ project }}/bin/setenv.sh:
  file.managed:
    - source: salt://manage/files/setenv-{{ project }}.sh
    - user: root
    - mode: 755
    - template: jinja

/data/www/{{ project }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/data/logs/{{ project }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/usr/local/tomcat-{{ project }}/webapps/ROOT:
  file.symlink:
  - target: /data/www/{{ project }}

/usr/local/tomcat-{{ project }}/logs:
  file.symlink:
  - target: /data/logs/{{ project }}

tomcat-{{ project }}_service:
  file.managed:
    - name: /usr/lib/systemd/system/tomcat-{{ project }}.service
    - source: salt://manage/files/tomcat-{{ project }}.service
    - user: root
    - mode: 755
    - template: jinja
    - defaults:
        project: {{ project }}
  service.running:
    - name: tomcat-{{ project }}
    - enable: True
    - restart: True
    - watch:
      - file: /usr/local/tomcat-{{ project }}/conf/server.xml
{% endfor %}

/etc/filebeat/filebeat.yml:
  file.managed:
    - source: salt://manage/files/filebeat.yml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - watch_in:
      - service: filebeat_service