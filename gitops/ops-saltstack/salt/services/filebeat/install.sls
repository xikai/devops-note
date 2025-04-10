filebeat_GPG_repository:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

/etc/yum.repos.d/elastic.repo:
  file.managed:
    - source: salt://services/filebeat/files/elastic.repo
    - user: root
    - group: root
    - mode: 644

filebeat_jdk_pkg:
  pkg.installed:
    - pkgs: 
      - filebeat

filebeat_service:
  service.running:
    - name: filebeat
    - enable: True
    - restart: True